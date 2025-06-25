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

  // Deploy TestIsm first
  const testIsm = m.contract('TestIsm', []);

  // Deploy Mailbox
  const mailbox = m.contract('Mailbox', [LOCAL_DOMAIN]);

  // Deploy MerkleTreeHook with mailbox address
  const merkleTreeHook = m.contract('MerkleTreeHook', [mailbox]);

  // Deploy ProtocolFee hook with specified parameters
  const protocolFeeHook = m.contract('ProtocolFee', [
    '100000000000000000', // maxProtocolFee
    '0', // protocolFee
    '0xFeb8E9Daa0b52D3D0A4615098C3A2FB0c55F13ED', // beneficiary
    '0xFeb8E9Daa0b52D3D0A4615098C3A2FB0c55F13ED' // owner
  ]);

  // Initialize the Mailbox with TestIsm, MerkleTreeHook as default, and ProtocolFee as required
  m.call(mailbox, 'initialize', [
    m.getParameter<string>('owner'),
    testIsm, // Use deployed TestIsm as the default ISM
    merkleTreeHook, // Use deployed MerkleTreeHook as default hook
    protocolFeeHook // Use ProtocolFee as required hook
  ]);

  // Deploy HypERC20 using the deployed mailbox address
  const hypERC20 = m.contract('HypERC20', [DECIMALS, SCALE, mailbox]);

  // Initialize the token
  m.call(hypERC20, 'initialize', [
    TOTAL_SUPPLY,
    TOKEN_NAME,
    TOKEN_SYMBOL,
    merkleTreeHook, // Use deployed MerkleTreeHook for HypERC20
    testIsm, // Use deployed TestIsm for HypERC20 as well
    m.getParameter<string>('owner')
  ]);

  return { testIsm, mailbox, merkleTreeHook, protocolFeeHook, hypERC20 };
});