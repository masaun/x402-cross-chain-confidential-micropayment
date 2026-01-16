use aztec::macros::aztec;
pub mod test;
pub mod types;

/**
 * @title - X402CrossChainConfidentialMicropaymentManager using zkTLS
 * @dev - A contract that demonstrates API request authorization using zkTLS.
 */
#[aztec]
pub contract X402CrossChainConfidentialMicropaymentManager {
    // aztec library imports
    use aztec::{
        context::{PrivateContext, PublicContext},
        keys::getters::{get_nsk_app, get_public_keys},
        macros::{
            functions::{external, initializer, internal, view}, 
            storage::storage,
            notes::{
                note,
                custom_note
            },
        },
        //messages::logs::note,
        note::{
            note_emission::OuterNoteEmission,
            note_getter_options::{NoteGetterOptions, SortOrder},
            note_interface::{NoteProperties, NoteHash, NoteType},
            note_viewer_options::NoteViewerOptions,
            retrieved_note::RetrievedNote
        },
        protocol_types::{
            address::AztecAddress,
            constants::{
                GENERATOR_INDEX__NOTE_HASH, GENERATOR_INDEX__NOTE_NULLIFIER,
                GENERATOR_INDEX__PARTIAL_NOTE_VALIDITY_COMMITMENT,
            },
            hash::poseidon2_hash_with_separator,
            traits::{Deserialize, Hash, Packable, Serialize, ToField},
        },
        state_vars::{
            PublicImmutable, PublicMutable, DelayedPublicMutable,
            PrivateImmutable, PrivateMutable, PrivateSet, 
            Map
        },
        oracle::random::random,
        event::{
            event_emission::emit_event_in_private,
            event_selector::EventSelector,
            event_interface::EventInterface,
        },
        messages::message_delivery::MessageDelivery
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

    // @dev - Import a "BoundedVec" type
    use std::collections::bounded_vec;

    // @dev - Import the AttVerifier contract (primus_zktls/att_verifier/src/main.nr)
    use att_verifier::AttVerifier;

    // @dev - Import the BusinessProgram contract (primus_zktls/basic_business_program/src/main.nr)
    use basic_business_program::BusinessProgram;

    // @dev - Import ZkTlsProofSet struct
    use crate::types::zktls_proof_set::{ZkTlsProofSet}; 

    /**********************************
     *   @notice - Global Variables   *
     **********************************/ 
    global MAX_ZKTLS_PROOF_LENGTH: u32 = 8192;  // Maximum length for zkTLS proof
    global MAX_AMOUNT_LENGTH: u32 = 32;         // Maximum length for amount in bytes

    /*************************
     *   @notice - Storage   *
     *************************/
    // @param owner The address of the owner
    // @param counter A numerical value
    #[storage]
    struct Storage<Context> {
        owner: PublicImmutable<AztecAddress, Context>,
        authorized_api_request_id: PublicMutable<u128, Context>,
        zktls_proof: Map<AztecAddress, ZkTlsProofSet<Context>, Context>,
        //zktls_proof: Map<u128, bounded_vec::BoundedVec<u8, MAX_ZKTLS_PROOF_LENGTH>, Context>,
        //wallets: Map<AztecAddress, WalletSet<Context>, Context>,    
    }

    /*****************************************
     *   @notice - Initialize & Constructor  *
     *****************************************/
    /// @dev Initialize the contract
    /// @param owner The address of the owner
    #[external("public")]
    #[initializer]
    fn constructor(owner: AztecAddress) {
        storage.owner.initialize(owner);
    }

    /***********************************
     *   @notice - External functions  *
     ***********************************/
    /// @dev - Authorizes an x402 API request/response of the Cronos x402 facilitator's "Verify" Endpoint using zkTLS proof (via the Primus old version for Cronos?)
    /// @dev - ref/Cronos API Reference: https://docs.cronos.org/cronos-x402-facilitator/api-reference
    /// @dev - ref/Cronos e2e Payment Flow: https://docs.cronos.org/cronos-x402-facilitator/how-it-works#payment-flow
    /// @param x402_api_proof_from_zktls - The zkTLS proof for the Cronos x402 facilitator's "Verify" Endpoint request/response. (NOTE: Not zkTLS proof for the x402 "Settle" Endpoint)
    ///                                  - Because we should replace the "Settle" flow with our private/confidential payment way. 
    #[external("private")]
    fn authorize_cronos_x402_facilitator_based_verify_endpoint(
        zktls_proof_for_x402_verify_endpoint_req_and_res: BoundedVec<u8, MAX_ZKTLS_PROOF_LENGTH>, 
        amount_to_be_transfered_from_public_inputs_of_zktls_proof: BoundedVec<u8, MAX_AMOUNT_LENGTH>
    ) {
        let x402_crosschain_confidential_micropayment_manager = X402CrossChainConfidentialMicropaymentManager::at(context.this_address());

        // [TODO]: Store a givnen zkTLS proof and its publicInputs into the contract storage using the "ZkTlsProofSet" struct


        // [TODO]: Implementation for authorizing a API response for an x402 verfication request (using Verify Endpoint: POST /v2/x402/verify)
        // [TODO]: Parse a response from the Verify Endpoint to check if the API request is authorized or not
        // [ref - Verify Endpoint]: https://docs.cronos.org/cronos-x402-facilitator/api-reference#verify-endpoint
        //
        // [Headers]:
        //
        // Content-Type: application/json
        // X402-Version: 1
        //
        // [Request Body]: -> NOTE: This is done by zkTLS protocol and a ZKProof is generated via zkTLS protocol (i.e. Primus).
        //
        // {
        //     "x402Version": 1,
        //     "paymentHeader": "eyJ4NDAyVmVyc2lvbiI6MS4uLn0=",
        //     "paymentRequirements": {
        //         "scheme": "exact",
        //         "network": "cronos-testnet",
        //         "payTo": "0xSeller...",
        //         "asset": "0xUSDCE...",
        //         "maxAmountRequired": "1000000",
        //         "maxTimeoutSeconds": 300
        //     }
        // }
        //
        // [Success Response]:
        //
        // {
        //     "isValid": true,
        //     "invalidReason": null
        // }
    }

    /// @dev - Lock the funds-settled from EVM to Aztec (EVM -> Aztec) - after an x402 API request/response of the Cronos's x402 "Verify" Endpoint would be verified.
    #[external("private")]
    fn lock_settlement_from_evm_to_aztec(
        aztec_gateway_7683_contract_address: AztecAddress,
        aztec_sender_address: AztecAddress,
        evm_l2_recipient_address: AztecAddress,
        evm_l2_asset_address: AztecAddress,
        amount: u128
    ) {
        // @dev - Create the contract instance of the X402CrossChainConfidentialMicropaymentManager contract
        let x402_crosschain_confidential_micropayment_manager = X402CrossChainConfidentialMicropaymentManager::at(context.this_address());

        // @dev - Create the contract instance of the X402PrivatePaymentRouter contract
        let aztec_gateway_7683 = AztecGateway7683::at(aztec_gateway_7683_contract_address);

        // [EVM -> Aztec]: We can see the claim_private() method is called in the e2e test (aztec_gateway_7683/scripts/e2e/evm-to-aztec.ts)
        //
        // await gateway.methods
        //     .claim_private(
        //         secret,
        //         Array.from(hexToBytes(orderId.toString())),
        //         Array.from(hexToBytes(log.originData as `0x${string}`)),
        //         Array.from(hexToBytes(log.fillerData as `0x${string}`)),
        //     )

        // [Aztec -> EVM]: We can see the open_private() method is called in the e2e test (aztec_gateway_7683/scripts/e2e/aztec-to-evm.ts)
        //
        // const receipt = await gateway.methods
        //     .open_private({
        //         fill_deadline: fillDeadline,
        //         order_data: Array.from(hexToBytes(orderData.encode())),
        //         order_data_type: Array.from(hexToBytes(ORDER_DATA_TYPE)),
        //      })


        // [TODO]: Settle the payment from the aztec_gateway_7683_contract_address to a recipient (evm_l2_recipient_address)
        // [TODO]: Using/Integrating the "aztec_gateway_7683" contract to settle the payment via confidential channel

        // @dev - [ref]: claim_private()
        //
        // fn claim_private(
        //     secret: Field,
        //     order_id_bytes: [u8; 32],
        //     origin_data_bytes: [u8; ORDER_DATA_LENGTH],
        //     filler_data_bytes: [u8; 32],
        // ) {

        // @dev - Call the claim_private() of the aztec_gateway_7683 contract
        let secret: Field = 12345678910;
        let order_id_bytes: [u8; 32] = [0u8; 32];
        let origin_data_bytes: [u8; ORDER_DATA_LENGTH] = [0u8; ORDER_DATA_LENGTH];
        let filler_data_bytes: [u8; 32] = [0u8; 32];

        // @dev - [EVM -> Aztec]
        aztec_gateway_7683.claim_private(
            secret,
            order_id_bytes,
            origin_data_bytes,
            filler_data_bytes,
        ).call(&mut context);
    }

    /// @dev - Unlock the funds-settled from Aztec to EVM (Aztec -> EVM)
    #[external("private")]
    fn unlock_settlement_from_aztec_to_evm(
        aztec_gateway_7683_contract_address: AztecAddress,
        aztec_sender_address: AztecAddress,
        evm_l2_recipient_address: AztecAddress,
        evm_l2_asset_address: AztecAddress,
        amount: u128
    ) {
        // @dev - Create the contract instance of the X402CrossChainConfidentialMicropaymentManager contract
        let x402_crosschain_confidential_micropayment_manager = X402CrossChainConfidentialMicropaymentManager::at(context.this_address());

        // @dev - Create the contract instance of the X402PrivatePaymentRouter contract
        let aztec_gateway_7683 = AztecGateway7683::at(aztec_gateway_7683_contract_address);

        // @dev - [ref]: The OnchainCrossChainOrder struct
        //
        // pub struct OnchainCrossChainOrder {
        //     pub fill_deadline: u32,
        //     pub order_data_type: [u8; 32],
        //     pub order_data: [u8; ORDER_DATA_LENGTH],
        // }

        // @dev - Create a OnchainCrossChainOrder struct data
        let onchain_cross_chain_order = OnchainCrossChainOrder {
            fill_deadline: 0,
            order_data_type: [0u8; 32],
            order_data: [0u8; ORDER_DATA_LENGTH]
        };

        // @dev - [Aztec -> EVM]
        aztec_gateway_7683.open_private(onchain_cross_chain_order).call(&mut context);

        // @dev - [ref]: open_private()
        //
        // fn open_private(order: OnchainCrossChainOrder) {...}
    }



    /// @dev Increments the authorized API request id
    #[external("private")]
    fn increment_authorized_api_request_id() {
        let x402_crosschain_confidential_micropayment_manager = X402CrossChainConfidentialMicropaymentManager::at(context.this_address());
        x402_crosschain_confidential_micropayment_manager.increment_authorized_api_request_id_internal().enqueue(&mut context);
    }

    /************************************
     *   @notice - Internal functions   *
     ************************************/
    /// @dev Increments the authorized API request id
    #[external("public")]
    #[internal]
    fn increment_authorized_api_request_id_internal() {
        let current_authorized_api_request_id = storage.authorized_api_request_id.read();
        storage.authorized_api_request_id.write(current_authorized_api_request_id + 1);
    }

    /********************************
     *   @notice - View functions   *
     ********************************/
    /// @dev Retrieves the owner of the contract
    /// @return The owner of the contract
    #[external("public")]
    #[view]
    fn get_owner() -> AztecAddress {
        storage.owner.read()
    }

    /// @dev Retrieves the authorized API request id
    /// @return The current authorized API request id
    #[external("public")]
    #[view]
    fn get_authorized_api_request_id() -> u128 {
        storage.authorized_api_request_id.read()
    }
}
