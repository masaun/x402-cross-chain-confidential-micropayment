import { createLogger } from "@aztec/foundation/log"
import type { DeployOptions } from "@aztec/aztec.js/contracts"
import { SponsoredFeePaymentMethod } from "@aztec/aztec.js/fee"
import { TokenContract } from "@defi-wonderland/aztec-standards/artifacts/Token.js"
import { Fr } from "@aztec/aztec.js/fields"
import { getSponsoredFPCAddress } from "../../../../aztec_gateway_7683/scripts/fpc.js"
import { getTestWallet, addAccountWithSecretKey } from "../../../../aztec_gateway_7683/scripts/utils.js"

const [, , tokenName = "dev.USDC.e", tokenSymbol = "DEV_USDC_E", tokenDecimalsStr = "6", rpcUrl = "https://devnet.aztec-labs.com"] =
  process.argv

const main = async () => {
  const logger = createLogger("deploy-token-auto")
  
  // Generate credentials
  const aztecSecretKey = Fr.random().toString()
  const aztecSalt = Fr.random().toString()
  const tokenDecimals = parseInt(tokenDecimalsStr)
  
  logger.info("=====================================")
  logger.info("Generated Aztec Account Credentials:")
  logger.info("=====================================")
  logger.info(`Secret Key: ${aztecSecretKey}`)
  logger.info(`Salt: ${aztecSalt}`)
  logger.info("=====================================")
  logger.info("IMPORTANT: Save these values securely!")
  logger.info("=====================================")
  logger.info("")
  logger.info(`Deploying token: ${tokenName} (${tokenSymbol}) with ${tokenDecimals} decimals`)
  logger.info(`RPC URL: ${rpcUrl}`)
  logger.info("")

  const wallet = await getTestWallet(rpcUrl)
  const paymentMethod = new SponsoredFeePaymentMethod(await getSponsoredFPCAddress())
  
  logger.info("Deploying account...")
  const account = await addAccountWithSecretKey({
    secretKey: aztecSecretKey,
    salt: aztecSalt,
    testWallet: wallet,
    deploy: true,
    paymentMethod,
  })
  logger.info(`Account deployed at: ${account.getAddress().toString()}`)

  const tokenDeployMethod = TokenContract.deployWithOpts(
    {
      wallet: wallet,
      method: "constructor_with_minter",
    },
    tokenName,
    tokenSymbol,
    tokenDecimals,
    account.getAddress(),
    account.getAddress(),
  )
  const deployOptions: DeployOptions = {
    from: account.getAddress(),
    fee: { paymentMethod },
  }

  const token = await tokenDeployMethod.send(deployOptions).deployed({
    timeout: 120000,
  })

  await wallet.registerContract({
    instance: token.instance,
    artifact: TokenContract.artifact,
  })

  logger.info(`token deployed: ${token.address.toString()}`)
  logger.info("")
  logger.info("=====================================")
  logger.info("Deployment Summary:")
  logger.info("=====================================")
  logger.info(`Token Name: ${tokenName}`)
  logger.info(`Token Symbol: ${tokenSymbol}`)
  logger.info(`Decimals: ${tokenDecimals}`)
  logger.info(`Token Address: ${token.address.toString()}`)
  logger.info(`Account Address: ${account.getAddress().toString()}`)
  logger.info(`Secret Key: ${aztecSecretKey}`)
  logger.info(`Salt: ${aztecSalt}`)
  logger.info("=====================================")
}

main().catch((err) => {
  console.error("❌", err)
  if (err && err.stack) {
    console.error(err.stack)
  }
  process.exit(1)
})
