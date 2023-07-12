const  { ethers, upgrades } =  require("hardhat");

async function main() {

  const PricePredictionUpgradeable = await ethers.getContractFactory(
    "PricePrediction"
  );
  const pricePredictionUpgradeable = await upgrades.deployProxy(
    PricePredictionUpgradeable,
    ["0x946B89D484ae795d4E80993147c8A06Bc009714c", "0xf4030086522a5beea4988f8ca5b36dbc97bee88c"],
    {
      initializer: "_PricePrediction_init",
    }
  );

  await pricePredictionUpgradeable.waitForDeployment();

  console.log(
    "pricePredictionUpgradeable deployed to:",
    pricePredictionUpgradeable.getAddress()
  );
}
//0x443bde294288fc420b9cbfdf5cde7db4fa0eefd3
//0x0387c859FBe90C36D2613Aa1FeeCFE57045dB522
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});