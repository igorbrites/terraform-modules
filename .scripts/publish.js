import { registerModule } from "./utils.js";

const init = async () => {
  await registerModule(
    process.env.npm_package_name,
    process.env.npm_package_provider,
    process.env.npm_package_version
  );
};

init()
  .then(() => {
    console.log("Finished");
  })
  .finally(() => {
    process.exit();
  });
