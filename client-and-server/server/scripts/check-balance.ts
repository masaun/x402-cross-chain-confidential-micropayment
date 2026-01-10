import { ethers } from 'ethers';
import dotenv from 'dotenv';

dotenv.config();

const RPC_URL = process.env.CRONOS_NETWORK === 'mainnet'
  ? 'https://evm.cronos.org'
  : 'https://evm-t3.cronos.org';

const provider = new ethers.JsonRpcProvider(RPC_URL);

async function checkBalance(tokenAddress: string, accountAddress: string, spenderAddress?: string) {
  try {
    const erc20 = new ethers.Contract(
      tokenAddress,
      [
        'function balanceOf(address) view returns (uint256)',
        'function decimals() view returns (uint8)',
        'function allowance(address,address) view returns (uint256)',
        'function name() view returns (string)',
        'function symbol() view returns (string)',
      ],
      provider
    );

    const [decimals, balanceRaw, name, symbol] = await Promise.all([
      erc20.decimals(),
      erc20.balanceOf(accountAddress),
      erc20.name().catch(() => 'Unknown'),
      erc20.symbol().catch(() => 'Unknown'),
    ]);

    console.log('\n📊 Token Information');
    console.log('='.repeat(50));
    console.log(`Token: ${name} (${symbol})`);
    console.log(`Address: ${tokenAddress}`);
    console.log(`Decimals: ${decimals}`);
    console.log('');
    console.log(`Account: ${accountAddress}`);
    console.log(`Balance (raw): ${balanceRaw.toString()}`);
    console.log(`Balance (human): ${ethers.formatUnits(balanceRaw, decimals)} ${symbol}`);

    if (spenderAddress) {
      const allowanceRaw = await erc20.allowance(accountAddress, spenderAddress);
      console.log('');
      console.log(`Spender: ${spenderAddress}`);
      console.log(`Allowance (raw): ${allowanceRaw.toString()}`);
      console.log(`Allowance (human): ${ethers.formatUnits(allowanceRaw, decimals)} ${symbol}`);
    }

    console.log('='.repeat(50));
  } catch (error) {
    console.error('❌ Error checking balance:', error);
    throw error;
  }
}

// CLI usage
const args = process.argv.slice(2);
if (args.length < 2) {
  console.log('Usage: ts-node check-balance.ts <tokenAddress> <accountAddress> [spenderAddress]');
  console.log('\nExample from error:');
  console.log('  ts-node check-balance.ts 0xc01efAaF7C5C61bEbFAeb358E1161b537b8bC0e0 0xad14B261c7B9D282AdC1410633266F0AE37468AA');
  process.exit(1);
}

const [tokenAddress, accountAddress, spenderAddress] = args;
checkBalance(tokenAddress, accountAddress, spenderAddress).catch(console.error);
