import '@nomiclabs/hardhat-ethers';
import '@nomiclabs/hardhat-waffle';
import 'dotenv/config';
import '@typechain/hardhat';
import 'hardhat-gas-reporter';
import 'hardhat-ignore-warnings';
import 'solidity-coverage';
import '@nomicfoundation/hardhat-ignition';
import '@nomicfoundation/hardhat-ignition-ethers';

import { rootHardhatConfig } from './rootHardhatConfig.cjs';

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  ...rootHardhatConfig,
  networks: {
    seaseedtest: {
      url: 'https://rpc.testnet.seaseed.network',
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
    },
  },
  gasReporter: {
    currency: 'USD',
  },
  typechain: {
    outDir: './core-utils/typechain',
    target: 'ethers-v5',
    alwaysGenerateOverloads: true,
    node16Modules: true,
  },
};
