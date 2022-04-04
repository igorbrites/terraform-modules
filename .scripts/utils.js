import fetch from "node-fetch";
import { mkdtempSync, createReadStream, readdirSync } from "fs";
import { tmpdir } from "os";
import { sep, basename, extname } from "path";
import { create } from "tar";

const pack = async (packageName, version) => {
  const tempFolder = mkdtempSync(`${tmpdir()}${sep}tf-`);
  const tarName = `${tempFolder}${sep}${packageName}-${version}.tgz`;

  await create(
    {
      gzip: true,
      noDirRecurse: false,
      file: tarName,
      filter: (name) => {
        const files = [
          ".cache",
          ".env",
          ".secrets",
          ".terraform",
          ".terraformrc",
          "CHANGELOG.md",
          "examples",
          "package-lock.json",
          "package.json",
        ];
        const ext = [
          ".gz",
          ".lock",
          ".log",
          ".pid",
          ".tar.gz",
          ".tfstate",
          ".tfvars",
          ".tgz",
        ];

        return !files.includes(basename(name)) && !ext.includes(extname(name));
      },
    },
    readdirSync(".")
  );

  return tarName;
};

const request = async (url, options, revert = null, validate = true) => {
  const res = await fetch(url, options);
  let body = await res.text();
  let isJSON = true;

  try {
    body = JSON.parse(body);
  } catch {
    isJSON = false;
  }

  if (!res.ok && validate) {
    if (typeof revert == "function") {
      revert();
    }

    process.exitCode = 1;

    switch (res.status) {
      case 403:
        console.error("Forbidden");
        break;

      case 404:
        console.error("User not authorized");
        break;

      case 422:
        console.error("Malformed request body");
        break;

      default:
        console.error(`Unkkown error (${res.status}: ${res.statustext})`);
        break;
    }

    const message = isJSON
      ? Array(json.errors).reduce(
          (prev, next) => `${prev.detail}; ${next.detail}`
        )
      : body;

    throw new Error(message);
  }

  return body;
};

export const registerModule = async (packageName, provider, version) => {
  console.log(`Registering module ${packageName}`);

  // ref: https://www.terraform.io/docs/cloud/api/modules.html#create-a-module-with-no-vcs-connection-
  const url = `https://app.terraform.io/api/v2/organizations/${process.env.ORGANIZATION_NAME}/registry-modules`;
  const name = packageName.replace(`terraform-${provider}-`, "");
  await request(
    url,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${process.env.TERRAFORM_CLOUD_TOKEN}`,
        "Content-Type": "application/vnd.api+json",
      },
      body: JSON.stringify({
        data: {
          type: "registry-modules",
          attributes: {
            name: `${name}`,
            provider: `${provider}`,
            "registry-name": "private",
          },
        },
      }),
    },
    null,
    false
  );

  console.log(`Module ${packageName} registered successfully!`);
  await generateUploadLink(packageName, name, provider, version);
};

const generateUploadLink = async (packageName, name, provider, version) => {
  console.log(`Generating upload link to publish ${packageName}`);

  // ref: https://www.terraform.io/docs/cloud/api/modules.html#create-a-module-version
  const url = `https://app.terraform.io/api/v2/organizations/${process.env.ORGANIZATION_NAME}/registry-modules/private/${process.env.ORGANIZATION_NAME}/${name}/${provider}/versions`;
  const options = {
    method: "POST",
    headers: {
      Authorization: `Bearer ${process.env.TERRAFORM_CLOUD_TOKEN}`,
      "Content-Type": "application/vnd.api+json",
    },
    body: JSON.stringify({
      data: {
        type: "registry-module-versions",
        attributes: {
          version: `${version}`,
        },
      },
    }),
  };

  const res = await request(url, options, async () => {
    await removeVersion(name, provider, version);
  });

  console.log(`Upload link generated for module ${packageName} successfully!`);
  await uploadModule(packageName, name, version, res.data.links.upload);
};

const uploadModule = async (packageName, name, version, link) => {
  console.log(`Uploading package por module ${packageName}`);

  const tarFile = await pack(packageName, version);
  const options = {
    method: "PUT",
    body: createReadStream(tarFile),
    headers: {
      "Content-Type": "application/octet-stream",
    },
  };

  // ref: https://www.terraform.io/docs/cloud/api/modules.html#upload-a-module-version-private-module-
  await request(link, options, async () => {
    await removeVersion(packageName, name, provider, version);
  });

  console.log(`Module ${packageName} uploaded to TF Cloud successfully!`);
};

const removeVersion = async (name, provider, version) => {
  process.exitCode = 1;

  // ref: https://www.terraform.io/docs/cloud/api/modules.html#delete-a-module
  const url = `https://app.terraform.io/api/v2/organizations/${process.env.ORGANIZATION_NAME}/registry-modules/private/${process.env.ORGANIZATION_NAME}/${name}/${provider}/${version}`;

  await request(url, {
    method: "DELETE",
    headers: {
      Authorization: `Bearer ${process.env.TERRAFORM_CLOUD_TOKEN}`,
      "Content-Type": "application/vnd.api+json",
    },
  });

  console.log("Module removed.");
};
