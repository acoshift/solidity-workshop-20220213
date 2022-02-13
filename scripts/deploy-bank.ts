import { ethers } from 'hardhat'
import { Bank__factory, BankToken__factory } from '../typechain'

async function main() {
  const signers = await ethers.getSigners()

  const BankToken = new BankToken__factory(signers[0])
  const bankToken = await BankToken.deploy()
  await bankToken.deployed()
  console.log('BankToken deployed to:', bankToken.address)

  const Bank = new Bank__factory(signers[0])
  const bank = await Bank.deploy(
    '0xa9bcB45E794C7dEb3D2D18eb83EC5f060c835BE4',
    bankToken.address
  )
  await bank.deployed()
  console.log('Bank deployed to:', bank.address)

  await bankToken.transferOwnership(bank.address)
  console.log('BankToken ownership transferred to Bank')

  await bank.setEmission(ethers.utils.parseEther('0.1'))
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
