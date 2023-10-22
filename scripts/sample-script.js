// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.

import { hre } from 'hardhat'
import { ecsign, toRpcSig, keccak256 } from 'ethereumjs-util'

async function main() {
    // 签名
  //bytes32 message = keccak256(abi.encodePacked(_msgSender(), amount, deadline, _useNonce));
  const sender = '0xB5eF866Aa826E1428f38b0C9396F8348167e44fD';
  const amount = 100;
  const deadline = 100000;
  const nonce = 1;

  //abi.encodePacked(_msgSender(), amount, deadline, _useNonce)
  let message = ethers.utils.solidityPack(
    ['address', 'uint256', 'uint256', 'uint256'],
    [sender.toLowerCase(), nonce, deadline, amount]
  );
  // keccak256(message)
  message = ethers.utils.keccak256(message);


  let privateKey: string = '0x7f0ef6c943faa45cf9bc338bc051821e78201870c034464499bb9024f3f7e27e';
  const msg1 = Buffer.concat([
      Buffer.from('\x19Ethereum Signed Message:\n32', 'ascii'),
      Buffer.from(arrayify(message))
  ])
  const sig = ecsign(keccak256(msg1), Buffer.from(arrayify(privateKey)))
  const signedMessage = toRpcSig(sig.v, sig.r, sig.s);
  console.log('signedMessage', signedMessage);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
