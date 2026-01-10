import express, { Request, Response } from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { Facilitator, CronosNetwork } from '@crypto.com/facilitator-client';
import { ethers } from 'ethers';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Initialize Facilitator
const network = process.env.CRONOS_NETWORK === 'mainnet' 
  ? CronosNetwork.CronosMainnet 
  : CronosNetwork.CronosTestnet;

const facilitator = new Facilitator({ network });

// Initialize signer
const getProvider = () => {
  const rpcUrl = process.env.CRONOS_NETWORK === 'mainnet'
    ? 'https://evm.cronos.org'
    : 'https://evm-t3.cronos.org';
  return new ethers.JsonRpcProvider(rpcUrl);
};

const getSigner = () => {
  if (!process.env.PRIVATE_KEY) {
    throw new Error('PRIVATE_KEY not set in environment');
  }
  return new ethers.Wallet(process.env.PRIVATE_KEY, getProvider());
};

// Routes

/**
 * GET /health
 * Health check endpoint
 */
app.get('/health', (req: Request, res: Response) => {
  res.json({ status: 'ok', network });
});

/**
 * GET /supported
 * Get supported networks and capabilities
 */
app.get('/supported', async (req: Request, res: Response) => {
  try {
    const capabilities = await facilitator.getSupported();
    res.json(capabilities);
  } catch (error) {
    console.error('Error getting supported capabilities:', error);
    res.status(500).json({ 
      error: 'Failed to get supported capabilities',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * GET /token-info/:tokenAddress/:accountAddress
 * Get token information and balance for a specific account
 */
app.get('/token-info/:tokenAddress/:accountAddress', async (req: Request, res: Response) => {
  try {
    const { tokenAddress, accountAddress } = req.params;
    const { spenderAddress } = req.query;

    const provider = getProvider();
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

    const result: any = {
      token: {
        address: tokenAddress,
        name,
        symbol,
        decimals: Number(decimals),
      },
      account: {
        address: accountAddress,
        balanceRaw: balanceRaw.toString(),
        balanceFormatted: ethers.formatUnits(balanceRaw, decimals),
      },
    };

    if (spenderAddress && typeof spenderAddress === 'string') {
      const allowanceRaw = await erc20.allowance(accountAddress, spenderAddress);
      result.allowance = {
        spender: spenderAddress,
        allowanceRaw: allowanceRaw.toString(),
        allowanceFormatted: ethers.formatUnits(allowanceRaw, decimals),
      };
    }

    res.json(result);
  } catch (error) {
    console.error('Error getting token info:', error);
    res.status(500).json({ 
      error: 'Failed to get token info',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * POST /generate-payment-header
 * Generate a Base64 EIP-3009 payment header
 * Body: { to: string, value: string, validBefore?: number }
 */
app.post('/generate-payment-header', async (req: Request, res: Response) => {
  try {
    const { to, value, validBefore } = req.body;

    if (!to || !value) {
      return res.status(400).json({ error: 'Missing required fields: to, value' });
    }

    const signer = getSigner();
    
    const header = await facilitator.generatePaymentHeader({
      to,
      value,
      signer,
      validBefore: validBefore || Math.floor(Date.now() / 1000) + 600, // 10 min default
    });

    res.json({ header });
  } catch (error) {
    console.error('Error generating payment header:', error);
    res.status(500).json({ 
      error: 'Failed to generate payment header',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * POST /generate-payment-requirements
 * Generate payment requirements
 * Body: { payTo: string, description: string, maxAmountRequired: string }
 */
app.post('/generate-payment-requirements', (req: Request, res: Response) => {
  try {
    const { payTo, description, maxAmountRequired } = req.body;

    if (!payTo || !description || !maxAmountRequired) {
      return res.status(400).json({ 
        error: 'Missing required fields: payTo, description, maxAmountRequired' 
      });
    }

    const requirements = facilitator.generatePaymentRequirements({
      payTo,
      description,
      maxAmountRequired,
    });

    res.json({ requirements });
  } catch (error) {
    console.error('Error generating payment requirements:', error);
    res.status(500).json({ 
      error: 'Failed to generate payment requirements',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * POST /verify-payment
 * Verify a payment request
 * Body: { header: string, requirements: object }
 */
app.post('/verify-payment', async (req: Request, res: Response) => {
  try {
    const { header, requirements } = req.body;

    if (!header || !requirements) {
      return res.status(400).json({ error: 'Missing required fields: header, requirements' });
    }

    const body = facilitator.buildVerifyRequest(header, requirements);
    const verifyResponse = await facilitator.verifyPayment(body);

    res.json(verifyResponse);
  } catch (error) {
    console.error('Error verifying payment:', error);
    res.status(500).json({ 
      error: 'Failed to verify payment',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * POST /settle-payment
 * Settle a verified payment
 * Body: { header: string, requirements: object }
 */
app.post('/settle-payment', async (req: Request, res: Response) => {
  try {
    const { header, requirements } = req.body;

    if (!header || !requirements) {
      return res.status(400).json({ error: 'Missing required fields: header, requirements' });
    }

    const body = facilitator.buildVerifyRequest(header, requirements);
    const settleResponse = await facilitator.settlePayment(body);

    res.json(settleResponse);
  } catch (error) {
    console.error('Error settling payment:', error);
    res.status(500).json({ 
      error: 'Failed to settle payment',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * POST /payment/full-flow
 * Complete end-to-end payment flow: generate, verify, and settle
 * Body: { receiverAddress: string, amount: string, description: string }
 */
app.post('/payment/full-flow', async (req: Request, res: Response) => {
  try {
    const { receiverAddress, amount, description } = req.body;

    if (!receiverAddress || !amount || !description) {
      return res.status(400).json({ 
        error: 'Missing required fields: receiverAddress, amount, description' 
      });
    }

    // Step 1: Generate payment header
    const signer = getSigner();
    const header = await facilitator.generatePaymentHeader({
      to: receiverAddress,
      value: amount,
      signer,
      validBefore: Math.floor(Date.now() / 1000) + 600, // 10 min expiry
    });

    console.log('Generated payment header:', header);

    // Step 2: Generate payment requirements
    const requirements = facilitator.generatePaymentRequirements({
      payTo: receiverAddress,
      description,
      maxAmountRequired: amount,
    });

    console.log('Generated payment requirements:', requirements);

    // Step 3: Build verify request
    const body = facilitator.buildVerifyRequest(header, requirements);

    // Step 4: Verify payment
    const verifyResponse = await facilitator.verifyPayment(body);
    console.log('Verification response:', verifyResponse);

    if (!verifyResponse.isValid) {
      return res.status(400).json({ 
        error: 'Payment verification failed',
        verifyResponse 
      });
    }

    // Step 5: Settle payment
    const settleResponse = await facilitator.settlePayment(body);
    console.log('Settlement response:', settleResponse);

    // Return complete flow result
    res.json({
      success: true,
      header,
      requirements,
      verifyResponse,
      settleResponse,
      txHash: settleResponse.txHash,
    });
  } catch (error) {
    console.error('Error in full payment flow:', error);
    res.status(500).json({ 
      error: 'Failed to complete payment flow',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 X402 Facilitator Server running on port ${PORT}`);
  console.log(`📡 Network: ${network}`);
  console.log(`\nAvailable endpoints:`);
  console.log(`  GET  /health - Health check`);
  console.log(`  GET  /supported - Get supported networks`);
  console.log(`  GET  /token-info/:tokenAddress/:accountAddress - Get token balance and info`);
  console.log(`  POST /generate-payment-header - Generate payment header`);
  console.log(`  POST /generate-payment-requirements - Generate payment requirements`);
  console.log(`  POST /verify-payment - Verify a payment`);
  console.log(`  POST /settle-payment - Settle a payment`);
  console.log(`  POST /payment/full-flow - Complete e2e payment flow`);
});

export default app;
