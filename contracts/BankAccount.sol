// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

contract BankAccount {
    constructor() {}

    event Deposit(
        address indexed user,
        uint indexed accountId,
        uint value,
        uint timestamp
    );
    event Withdraw(
        address indexed user,
        uint indexed accountId,
        uint indexed withdrawId,
        uint amount,
        uint timestamp
    );
    event Withdraw(uint indexed withdrawId, uint timestamp);
    event AccountCreated(
        address[] indexed owners,
        uint indexed id,
        uint timestamp
    );

    struct WithdrawRequest {
        address user;
        uint amount;
        uint approvals;
        bool approved;
        mapping(address => bool) ownersApproved;
    }

    struct Account {
        address[] owners;
        uint balance;
        mapping(uint => WithdrawRequest) withdrawRequest;
    }

    mapping(uint => Account) accounts;
    mapping(address => uint[]) userAccounts;

    uint nextAccountId;
    uint nextWithdrawId;

    modifier accountOwner(uint accountId) {
        bool isOwner;
        for (uint idx; idx < accounts[accountId].owners.length; idx++) {
            if (accounts[accountId].owners[idx] == msg.sender) {
                isOwner = true;
                break;
            }
        }

        require(isOwner, "You are not the owner account");
        _;
    }

    modifier validOwners(address[] calldata owners) {
        require(owners.length + 1 <= 4, "maximum of 4 owners per account");
        for (uint i; i < owners.length; i++) {
            for (uint j = i + 1; j < owners.length; j++) {
                if (owners[i] == owners[j]) {
                    revert("no duplicate owners");
                }
            }
        }
        _;
    }

    function deposit(uint accountId) external payable accountOwner(accountId) {
        accounts[accountId].balance += msg.value;
    }

    function createAccount(
        address[] calldata otherOwners
    ) external validOwners(otherOwners) {
        // limit of the owners + contract owner
        address[] memory owners = new address[](otherOwners.length + 1);
        owners[otherOwners.length] = msg.sender;

        uint id = nextAccountId;
        for (uint idx; idx < owners.length; idx++) {
            if (idx < owners.length - 1) {
                owners[idx] = otherOwners[idx];
            }
            if (userAccounts[owners[idx]].length > 2) {
                revert("each user can have a max of 3 accounts");
            }
            userAccounts[owners[idx]].push(id);
        }

        accounts[id].owners = owners;
        nextAccountId++;
        emit AccountCreated(owners, id, block.timestamp);
    }

    function requestWithdrawl(uint accountId, uint amount) external {}

    function approveWithdrawl(uint accountId, uint withdrawId) external {}

    function withdraw(uint accountId, uint withdrawId) external {}

    function getBalance(uint accountId) public view returns (uint) {}

    function getOwners(uint accountId) public view returns (address[] memory) {}

    function getApprolvals(
        uint accountId,
        uint withdrawId
    ) public view returns (uint) {}

    function getAccounts() public view returns (uint[] memory) {}
}
