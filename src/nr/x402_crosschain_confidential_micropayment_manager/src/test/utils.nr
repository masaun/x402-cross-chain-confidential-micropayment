use crate::X402CrossChainConfidentialMicropaymentManager;

use aztec::{
    protocol_types::{
        address::{AztecAddress, EthAddress},
        traits::ToField,
    },
    test::helpers::test_environment::TestEnvironment,
};

use aztec_gateway_7683::{
    AztecGateway7683, 
    types::{
        onchain_cross_chain_order::OnchainCrossChainOrder,
        order_data::{OrderData, ORDER_DATA_LENGTH, ORDER_DATA_TYPE, PUBLIC_ORDER},
    }
};

// @dev - Test setup structure for AztecGateway7683 contract tests.
pub struct TestSetup {
    pub gateway_contract_address: AztecAddress,
    pub owner: AztecAddress,
    pub user1: AztecAddress,
    pub user2: AztecAddress,
    pub l2_gateway: EthAddress,
    pub l2_gateway_domain: u32,
    pub forwarder: EthAddress,
}


/************************************************************************************************
 *   @notice - Setup function for X402CrossChainConfidentialMicropaymentManager contract tests  *
 ************************************************************************************************/
// @dev - Main setup function to deploy contracts and create accounts, and prepare the test environment.
pub unconstrained fn setup_contract(
    with_account_contracts: bool,
) -> (TestEnvironment, AztecAddress, AztecAddress, AztecAddress, AztecAddress, AztecAddress) {
    // @dev - Setup accounts and test environment
    let with_account_contracts = false;
    let (mut env, owner, user1, user2) = setup_accounts_and_env(with_account_contracts);

    // @dev - Deploy AztecGateway7683 contract
    let test_setup: TestSetup = deploy_aztec_gateway_7683_contract(&mut env, owner, user1, user2);
    let gateway_contract_address = test_setup.gateway_contract_address;

    // @dev - Deploy X402CrossChainConfidentialMicropaymentManager contract
    let x402_crosschain_confidential_micropayment_manager_contract_address = deploy_x402_crosschain_confidential_micropayment_manager_contract(&mut env, owner);

    (env, x402_crosschain_confidential_micropayment_manager_contract_address, gateway_contract_address, owner, user1, user2)
}

// @dev - Deploys the X402CrossChainConfidentialMicropaymentManager contract.
pub unconstrained fn deploy_x402_crosschain_confidential_micropayment_manager_contract(
    env: &mut TestEnvironment,
    owner: AztecAddress,
) -> AztecAddress {
    let initializer_call_interface = X402CrossChainConfidentialMicropaymentManager::interface().constructor(owner);
    let contract_address =
        env.deploy("@x402_crosschain_confidential_micropayment_manager/X402CrossChainConfidentialMicropaymentManager").with_public_initializer(owner, initializer_call_interface);

    contract_address
}

// @dev - Deploys the AztecGateway7683 contract with mock parameters.
pub unconstrained fn deploy_aztec_gateway_7683_contract(
    env: &mut TestEnvironment,
    owner: AztecAddress,
    user1: AztecAddress,
    user2: AztecAddress,
) -> TestSetup {
    // [ref]: AztecGateway7683 contract's constructor
    //
    // fn constructor(l2Gateway: EthAddress, l2GatewayDomain: u32, forwarder: EthAddress) {
    //     storage.config.initialize(Config { l2Gateway, l2GatewayDomain, forwarder });
    // }

    // Mock addresses for L2 gateway and forwarder
    let l2_gateway = EthAddress::from_field(0x1234567890abcdef);
    let l2_gateway_domain = 1; // Ethereum mainnet
    let forwarder = EthAddress::from_field(0xfedcba0987654321);

    let initializer_call_interface = AztecGateway7683::interface().constructor(l2_gateway, l2_gateway_domain, forwarder);
    let gateway_contract_address =
        env.deploy("@aztec_gateway_7683/AztecGateway7683").with_public_initializer(owner, initializer_call_interface);

    TestSetup {
        gateway_contract_address,
        owner,
        user1,
        user2,
        l2_gateway,
        l2_gateway_domain,
        forwarder,
    }
}

// @dev - Sets up accounts and the test environment.
pub unconstrained fn setup_accounts_and_env(
    with_account_contracts: bool,
) -> (TestEnvironment, AztecAddress, AztecAddress, AztecAddress) {
    // Setup env, generate keys
    let mut env = TestEnvironment::new();
    let (owner, user1, user2) = if with_account_contracts {
        let owner = env.create_contract_account();
        let user1 = env.create_contract_account();
        let user2 = env.create_contract_account();
        (owner, user1, user2)
    } else {
        let owner = env.create_light_account();
        let user1 = env.create_light_account();
        let user2 = env.create_light_account();
        (owner, user1, user2)
    };

    (env, owner, user1, user2)
}
