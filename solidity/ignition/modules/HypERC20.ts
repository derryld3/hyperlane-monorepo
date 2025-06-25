import { buildModule } from '@nomicfoundation/hardhat-ignition/modules';

export default buildModule('HypERC20', (m) => {
  console.log(m)
  // Deploy parameters
  const DECIMALS = 6;
  const SCALE = 1; // Scale factor for token transfers
  const TOTAL_SUPPLY = BigInt('1000000000000000000000000'); // 1 million tokens
  const TOKEN_NAME = 'Test USDC';
  const TOKEN_SYMBOL = 'TUSDC';
  const LOCAL_DOMAIN = 1; // Local domain for the mailbox

  // Deploy Mailbox first
  const mailbox = m.contract('Mailbox', [LOCAL_DOMAIN]);

  // Initialize the Mailbox
  m.call(mailbox, 'initialize', [
    m.getParameter<string>('owner'),
    m.getParameter<string>('interchainSecurityModule'),
    m.getParameter<string>('hook'),
    m.getParameter<string>('hook') // Using same hook for required hook
  ]);

  // Deploy HypERC20 using the deployed mailbox address
  const hypERC20 = m.contract('HypERC20', [DECIMALS, SCALE, mailbox]);

  // Initialize the token
  m.call(hypERC20, 'initialize', [
    TOTAL_SUPPLY,
    TOKEN_NAME,
    TOKEN_SYMBOL,
    m.getParameter<string>('hook'),
    m.getParameter<string>('interchainSecurityModule'),
    m.getParameter<string>('owner')
  ]);

  return { mailbox, hypERC20 };
});