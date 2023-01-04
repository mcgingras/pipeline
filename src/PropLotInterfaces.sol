// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract PropLotStorageV1 {
  struct Idea {
    /// @notice Unique id for looking up a proposal
    uint256 id;
    /// @notice Creator of the proposal
    address proposer;
    /// @notice the ordered list of target addresses for calls to be made
    address[] targets;
    /// @notice The ordered list of values (i.e. msg.value) to be passed to the calls to be made
    uint256[] values;
    /// @notice The ordered list of function signatures to be called
    string[] signatures;
    /// @notice The ordered list of calldata to be passed to each call
    bytes[] calldatas;
    /// @notice The hash of the description
    bytes32 descriptionHash;
    /// @notice Current number of votes in favor of this idea
    uint256 forVotes;
    /// @notice Current number of votes in opposition to this idea
    uint256 againstVotes;
    /// @notice Receipts of ballots for the entire set of voters
    mapping(address => Receipt) receipts;
  }

  /// @notice Ballot receipt record for a voter
  struct Receipt {
    /// @notice Whether or not a vote has been cast
    bool hasVoted;
    /// @notice Whether or not the voter supports the idea
    uint8 support;
    /// @notice The number of votes the voter had, which were cast
    uint96 votes;
  }
}