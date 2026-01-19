// @dev - Import the X402CrossChainConfidentialMicropaymentManager contract
use crate::{
    X402CrossChainConfidentialMicropaymentManager, 
    test::utils
};

// @dev - Import the AztecGateway7683 contract (aztec_gateway_7683/src/main.nr)
use aztec_gateway_7683::{
    AztecGateway7683, 
    types::{
        events::{Filled, Open, Settled},
        helpers::InternalRCOParams,
        onchain_cross_chain_order::OnchainCrossChainOrder,
        order_data::{
            ORDER_DATA_LENGTH, ORDER_DATA_TYPE, OrderData, PRIVATE_ORDER,
            PRIVATE_ORDER_WITH_HOOK, PUBLIC_ORDER, PUBLIC_ORDER_WITH_HOOK,
        },
        resolved_cross_chain_order::{
            FILL_INSTRUCTIONS_MAX_INSTRUCTIONS, FillInstruction, MAX_SPENT_MAX_OUTPUTS,
            MIN_RECEIVED_MAX_OUTPUTS, Output, RESOLVED_CROSS_CHAIN_LENGTH,
            ResolvedCrossChainOrder,
        },
    },
};

/**
 * @notice - Test for unlocking settlement from Aztec to EVM
 **/
#[test]
unconstrained fn unlock_settlement_from_aztec_to_evm_success() {
    let (env, x402_crosschain_confidential_micropayment_manager_contract_address, gateway_contract_address, owner, user1, user2) = utils::setup_contract(false);

    // @dev - Create the X402CrossChainConfidentialMicropaymentManager contract instance
    let x402_crosschain_confidential_micropayment_manager = X402CrossChainConfidentialMicropaymentManager::at(x402_crosschain_confidential_micropayment_manager_contract_address);

    // @dev - Create the X402PrivatePaymentRouter contract instance
    //let aztec_gateway_7683 = AztecGateway7683::at(aztec_gateway_7683_contract_address);

    // env.call_private(owner,x402_crosschain_confidential_micropayment_manager.increment_authorized_api_request_id());

    // let authorized_api_request_id = env.view_public(x402_crosschain_confidential_micropayment_manager.get_authorized_api_request_id());
    // assert(authorized_api_request_id == 1);
}