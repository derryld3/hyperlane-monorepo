import '@nomiclabs/hardhat-ethers';
import '@nomiclabs/hardhat-waffle';
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
