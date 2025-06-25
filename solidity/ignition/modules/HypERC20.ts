import { buildModule } from '@nomicfoundation/hardhat-ignition/modules';

export default buildModule('HypERC20', (m) => {
  console.log(m)
  // Deploy parameters
  const DECIMALS = 6;
  const SCALE = 1; // Scale factor for token transfers
  const TOTAL_SUPPLY = BigInt('1000000000000000000000000'); // 1 million tokens
  const TOKEN_NAME = 'Test USDC';
  const TOKEN_SYMBOL = 'TUSDC';

  // Deploy HypERC20
  const hypERC20 = m.contract('HypERC20', [DECIMALS, SCALE, m.getParameter<string>('mailbox')]);

  // Initialize the token
  m.call(hypERC20, 'initialize', [
    TOTAL_SUPPLY,
    TOKEN_NAME,
    TOKEN_SYMBOL,
    m.getParameter<string>('hook'),
    m.getParameter<string>('interchainSecurityModule'),
    m.getParameter<string>('owner')
  ]);

  return { hypERC20 };
});