import * as dotenv from "dotenv";

import { HardhatUserConfig, task, subtask } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";
const { getEtherscanEndpoints } = require("@nomiclabs/hardhat-etherscan/dist/src/network/prober")

dotenv.config();

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

const chainConfig: any = {
  reitestnet: {
    chainId: 55556,
    urls: {
      apiURL: "https://testnet.reiscan.com/api",
      browserURL: "https://testnet.reiscan.com/",
    }
  }
}

subtask('verify:get-etherscan-endpoint').setAction(async (_, { network }) =>
  getEtherscanEndpoints(network.provider, network.name, chainConfig)
);

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

// 0x008c2fbf6f083bEE8790a1854F38fCD90819085a

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.11",
    // settings: {
    //   optimizer: {
    //     enabled: true,
    //     runs: 200
    //   }
    // }
  },
  networks: {
    ropsten: {
      url: process.env.ROPSTEN_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    reitestnet: {
      url: "https://rei-testnet-rpc.moonrhythm.io",
      chainId: 55556,
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],

    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY || 'test',
  },
};

export default config;
