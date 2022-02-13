import { ethers } from 'hardhat'
import { Bank__factory } from '../typechain'

async function main() {
  const signers = await ethers.getSigners()

  const Bank = new Bank__factory(signers[0])
  const bank = Bank.attach('0x80F013de2fa2C9016d2eC7a45Ec277eC8dA7ae9E')

  await bank.setFee(100)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
