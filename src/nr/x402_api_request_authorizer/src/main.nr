use aztec::macros::aztec;
pub mod test;
pub mod types;

/**
 * @title - X402ApiRequestAuthorizer using zkTLS
 * @dev - A contract that demonstrates API request authorization using zkTLS.
 */
#[aztec]
pub contract X402ApiRequestAuthorizer {
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

    // @dev - Import a "BoundedVec" type
    use std::collections::bounded_vec;

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
    /// @dev - Authorizes an x402 API request/response of the Cronos's x402 "Verify" Endpoint using zkTLS proof (via the Primus old version for Cronos?)
    /// @dev - ref/Cronos API Reference: https://docs.cronos.org/cronos-x402-facilitator/api-reference
    /// @dev - ref/Cronos e2e Payment Flow: https://docs.cronos.org/cronos-x402-facilitator/how-it-works#payment-flow
    /// @param x402_api_proof_from_zktls - The zkTLS proof for the x402 "Verify" Endpoint request/response. (NOTE: Not zkTLS proof for the x402 "Settle" Endpoint)
    ///                                  - Because we should replace the "Settle" flow with our private/confidential payment way. 
    #[external("private")]
    fn authorize_x402_verify_endpoint_req_and_res(
        zktls_proof_for_x402_verify_endpoint_req_and_res: BoundedVec<u8, MAX_ZKTLS_PROOF_LENGTH>, 
        amount_to_be_transfered_from_public_inputs_of_zktls_proof: BoundedVec<u8, MAX_AMOUNT_LENGTH>
    ) {
        let x402_api_request_authorizer = X402ApiRequestAuthorizer::at(context.this_address());

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


    /// @dev Increments the authorized API request id
    #[external("private")]
    fn increment_authorized_api_request_id() {
        let x402_api_request_authorizer = X402ApiRequestAuthorizer::at(context.this_address());
        x402_api_request_authorizer.increment_authorized_api_request_id_internal().enqueue(&mut context);
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
