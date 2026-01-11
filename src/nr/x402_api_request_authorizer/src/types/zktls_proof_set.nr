use aztec::{
    context::{PrivateContext, UtilityContext},
    note::{
        note_emission::OuterNoteEmission,
        note_getter_options::{NoteGetterOptions, SortOrder},
        note_interface::NoteProperties,
        note_viewer_options::NoteViewerOptions,
        retrieved_note::RetrievedNote,
    },
    protocol_types::{address::AztecAddress, constants::MAX_NOTE_HASH_READ_REQUESTS_PER_CALL},
    state_vars::{PrivateSet, storage::HasStorageSlot},
};
use std::ops::Add;
use uint_note::uint_note::UintNote;


/***********************************************************
 *   @notice - Check whether it has a StorageSlot or not   *
 ***********************************************************/
// TODO(#13824): remove this impl once we allow structs to hold state variables.
impl<Context> HasStorageSlot<1> for ZkTlsProofSet<Context> {
    fn get_storage_slot(self) -> Field {
        self.zktls_proof.get_storage_slot()
        self.public_inputs.get_storage_slot()
    }
}

/***************************************************************************
 *   @notice - Set of ZkTlsProof struct (icl. zkTLS Proof, publicInputs)   *
 ***************************************************************************/
pub struct ZkTlsProofSet<Context> { // @dev - Since the "<Context>" is added here, the WalletSet can be recognized as a "Storage" struct.
    pub zktls_proof: PrivateSet<UintNote, Context>,
    pub public_inputs: PrivateSet<UintNote, Context>,
}

impl<Context> ZkTlsProofSet<Context> {
    pub fn new(context: Context, storage_slot: Field) -> Self {
        assert(storage_slot != 0, "Storage slot 0 not allowed. Storage slots must start from 1.");
        Self { zktls_proof: PrivateSet::new(context, storage_slot), public_inputs: PrivateSet::new(context, storage_slot) }
    }
}

impl ZkTlsProofSet<&mut PrivateContext> {
    // @dev - Example function for ZkTlsProofSet struct with PrivateContext.
    pub fn something_function(self: Self) -> OuterNoteEmission<UintNote> {
        OuterNoteEmission::new(Option::none(), self.zktls_proof.context)
    }

    // pub fn add(self: Self, owner: AztecAddress, addend: u128) -> OuterNoteEmission<UintNote> {
    //     let content = if addend == 0 as u128 {
    //         Option::none()
    //     } else {
    //         // We fetch the nullifier public key hash from the registry / from our PXE
    //         let mut addend_note = UintNote::new(addend, owner);

    //         Option::some(self.balance.insert(addend_note).content) // @dev - Add a given amount (added) to the existing balance.
    //     };

    //     OuterNoteEmission::new(content, self.balance.context)
    // }

    // pub fn sub(self: Self, owner: AztecAddress, amount: u128) -> OuterNoteEmission<UintNote> {
    //     let subtracted = self.try_sub(amount, MAX_NOTE_HASH_READ_REQUESTS_PER_CALL);
    
    //     // try_sub may have subtracted more or less than amount. We must ensure that we subtracted at least as much as
    //     // we needed, and then create a new note for the owner for the change (if any).
    //     assert(subtracted >= amount, "Balance too low");
    //     self.add(owner, subtracted - amount)
    // }
}