import { ethers, run } from 'hardhat'
import { TestToken__factory } from '../typechain'

async function main() {
  const signers = await ethers.getSigners()

  const C = new TestToken__factory(signers[0])
  const c = await C.deploy()
  await c.deployed()
  console.log('TestToken deployed to:', c.address)

  await run('verify:verify', {
    address: c.address,
    constructorArguments: [],
    contract: 'contracts/TestToken.sol:TestToken'
  })
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
