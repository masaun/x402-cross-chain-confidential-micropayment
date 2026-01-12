# Cross Chain Confidential Payment

## Overview

<br>

### Technical Stack

- Smart Contract: [`Noir`](https://noir-lang.org/docs/)
  - nargo/noirc: `v1.0.0-beta.16`

- Blockchain: [`Aztec` Network](https://docs.aztec.network/) (Ethereum L2 Rollup)
  - aztec package: `v3.0.0-devnet.2`


<br>

## Remarks

- This repo is originally forked from the [aztec-workshop](https://github.com/0xShaito/aztec-workshop) repo.

<br>

## Setup

1. Install Aztec by following the instructions from [their documentation](https://docs.aztec.network/developers/getting_started).
2. Install the dependencies by running: `yarn install`
3. Ensure you have Docker installed and running (required for Aztec sandbox)

<br>

## SC Compile & Build

The complete build pipeline includes cleaning, compiling Noir contracts, and generating TypeScript artifacts:

```bash
yarn ccc
```

This runs:
- `yarn clean` - Removes all build artifacts
- `yarn compile` - Compiles Noir contracts using aztec-nargo
- `yarn codegen` - Generates TypeScript bindings from compiled contracts

<br>

NOTE:
- Currently, the `partial_att_verifier` is moved to the `nr/pending` directory - due to `compile errors`-caused by the `aztec-packages` version mismatch (`v3.0.0-devnet.2` and `v3.0.0-devnet.5`).

<br>

## Smart Contract Test
### Noir tests only
Test your contract logic directly:

```bash
yarn test:nr
```

<br>

## e2e Test
### TypeScript integration tests only
Test contract interactions through TypeScript:

```bash
yarn test:js
```

<br>

## Resources

- [Aztec Documentation](https://docs.aztec.network/)
- [Noir Language Documentation](https://noir-lang.org/)
- [Aztec Sandbox Quickstart](https://docs.aztec.network/developers/getting_started)
- [Aztec Contracts Guide](https://docs.aztec.network/aztec/smart_contracts_overview)
