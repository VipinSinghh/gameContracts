// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
 

  const Game = await hre.ethers.getContractFactory("GAME_ERC20");
  const game = await Game.deploy();

  await game.deployed();

  console.log(
    `GAME ERC20 deployed to ${game.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
// contract address - GAME_ERC20 is 0x946B89D484ae795d4E80993147c8A06Bc009714c