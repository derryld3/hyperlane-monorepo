import { buildModule } from '@nomicfoundation/hardhat-ignition/modules';

export default buildModule('HypERC20BridgedUSDCModule', (m) => {
  // Deploy parameters
  const LOCAL_DOMAIN = 1; // Local domain for the mailbox

  // Get parameters for owner and usdcAddress
  const owner = m.getParameter('owner', '0x287804400a0671565750501070b0901070c09010');
  const usdcAddress = m.getParameter('usdcAddress', '0x287804400a0671565750501070b0901070c09010');

  // Deploy TestIsm
  const testIsm = m.contract('TestIsm', []);

  // Deploy Mailbox
  const mailbox = m.contract('Mailbox', [LOCAL_DOMAIN]);

  // Deploy MerkleTreeHook with mailbox address
  const merkleTreeHook = m.contract('MerkleTreeHook', [mailbox]);

  // Deploy ProtocolFee hook with specified parameters
  const protocolFeeHook = m.contract('ProtocolFee', [
    '100000000000000000', // maxProtocolFee
    '0', // protocolFee
    owner, // beneficiary
    owner // owner
  ]);

  // Initialize the Mailbox with TestIsm, MerkleTreeHook as default, and ProtocolFee as required
  m.call(mailbox, 'initialize', [
    owner,
    testIsm, // Use deployed TestIsm as the default ISM
    merkleTreeHook, // Use deployed MerkleTreeHook as default hook
    protocolFeeHook // Use ProtocolFee as required hook
  ]);

  // Deploy HypERC20_BridgedUSDC using the deployed mailbox address and usdcAddress
  const hypERC20BridgedUSDC = m.contract('HypERC20_BridgedUSDC', [
    mailbox,
    usdcAddress
  ]);

  return { testIsm, mailbox, merkleTreeHook, protocolFeeHook, hypERC20BridgedUSDC };
});