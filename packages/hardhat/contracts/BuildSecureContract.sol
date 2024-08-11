// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BuildSecureContract {
    address public builderAddress;
    address public buyerAddress;
    IERC20 public paymentToken;
    uint256 public totalAmount;
    uint256 public depositAmount;
    uint256 public penaltyAmount;
    uint256 public milestoneCount;
    bool public deliveryConfirmed;
    uint256 public refundDeadline;

    enum State { Created, PaymentMade, InProgress, Completed, Disputed, Canceled }
    State public contractState;

    struct Milestone {
        uint256 dueDate;
        bool completed;
        bool verified;
    }

    mapping(uint256 => Milestone) public milestones;
    uint256[] public milestoneIds;
    mapping(uint256 => uint256) public milestonePercentages;

    address public oracleAddress;

    modifier onlyBuyer() {
        require(msg.sender == buyerAddress, "Only the buyer can call this");
        _;
    }

    modifier onlyBuilder() {
        require(msg.sender == builderAddress, "Only the builder can call this");
        _;
    }

    modifier onlyOracle() {
        require(msg.sender == oracleAddress, "Only the oracle can call this");
        _;
    }

    modifier inState(State _state) {
        require(contractState == _state, "Invalid contract state");
        _;
    }

    event MilestoneAdded(uint256 milestoneId, uint256 dueDate);
    event PaymentMade(address buyer, uint256 amount);
    event MilestoneCompleted(uint256 milestoneId);
    event DeliveryConfirmed(address buyer);
    event RefundIssued(address buyer, uint256 amount);
    event PenaltyApplied(address user, uint256 amount);
    event DisputeResolved();

    constructor(
        address _builderAddress,
        address _buyerAddress,
        address _paymentToken,
        uint256 _totalAmount,
        uint256 _depositAmount,
        uint256 _penaltyAmount,
        address _oracleAddress,
        uint256 _refundDeadline
    ) {
        builderAddress = _builderAddress;
        buyerAddress = _buyerAddress;
        paymentToken = IERC20(_paymentToken);
        totalAmount = _totalAmount;
        depositAmount = _depositAmount;
        penaltyAmount = _penaltyAmount;
        oracleAddress = _oracleAddress;
        contractState = State.Created;
        refundDeadline = _refundDeadline;
    }

    function addMilestone(uint256 _milestoneId, uint256 _dueDate) public onlyBuilder inState(State.Created) {
        milestones[_milestoneId] = Milestone({
            dueDate: _dueDate,
            completed: false,
            verified: false
        });
        milestoneIds.push(_milestoneId);
        emit MilestoneAdded(_milestoneId, _dueDate);
    }

    function makePayment() public onlyBuyer inState(State.Created) {
        require(paymentToken.transferFrom(buyerAddress, address(this), depositAmount), "Payment failed");
        contractState = State.PaymentMade;
        emit PaymentMade(buyerAddress, depositAmount);
    }

    function startConstruction() public onlyBuilder inState(State.PaymentMade) {
        contractState = State.InProgress;
    }

    function completeMilestone(uint256 _milestoneId) public onlyOracle inState(State.InProgress) {
        require(block.timestamp >= milestones[_milestoneId].dueDate, "Milestone not yet due");
        milestones[_milestoneId].completed = true;
        milestones[_milestoneId].verified = true;
        emit MilestoneCompleted(_milestoneId);

        if (allMilestonesCompleted()) {
            releaseFunds();
        }
    }

    function confirmDelivery() public onlyBuyer inState(State.InProgress) {
        require(allMilestonesCompleted(), "Not all milestones completed");
        deliveryConfirmed = true;
        contractState = State.Completed;
        releaseFinalPayment();
        emit DeliveryConfirmed(buyerAddress);
    }

    function refundBuyerIfMilestoneFails(uint256 _milestoneId) public onlyOracle inState(State.InProgress) {
        require(!milestones[_milestoneId].completed, "Milestone already completed");
        require(block.timestamp > milestones[_milestoneId].dueDate, "Milestone not yet overdue");
        uint256 refundAmount = depositAmount;
        require(paymentToken.transfer(buyerAddress, refundAmount), "Refund failed");
        contractState = State.Canceled;
        emit RefundIssued(buyerAddress, refundAmount);
    }

    function penalizeBuilder() public onlyOracle inState(State.InProgress) {
        require(block.timestamp > milestones[milestoneIds[0]].dueDate && !milestones[milestoneIds[0]].completed, "First milestone not yet overdue or already completed");
        require(paymentToken.transfer(buyerAddress, penaltyAmount), "Penalty payment failed");
        contractState = State.Disputed;
        emit PenaltyApplied(builderAddress, penaltyAmount);
    }

    function penalizeBuyer() public onlyOracle inState(State.InProgress) {
        require(block.timestamp > milestones[milestoneIds[0]].dueDate && !deliveryConfirmed, "Contract not yet overdue or delivery already confirmed");
        uint256 penaltyAmountForBuyer = depositAmount; // Penalización para el comprador
        require(paymentToken.transfer(builderAddress, penaltyAmountForBuyer), "Penalty payment failed");
        contractState = State.Disputed;
        emit PenaltyApplied(buyerAddress, penaltyAmountForBuyer);
    }

    function resolveDispute(bool buyerWins) public onlyOracle inState(State.Disputed) {
        if (buyerWins) {
            uint256 refundAmount = depositAmount + penaltyAmount;
            require(paymentToken.transfer(buyerAddress, refundAmount), "Refund to buyer failed");
            contractState = State.Canceled;
        } else {
            uint256 remainingPayment = totalAmount - depositAmount;
            require(paymentToken.transfer(builderAddress, remainingPayment), "Payment to builder failed");
            contractState = State.Completed;
        }

        emit DisputeResolved();
    }

    function allMilestonesCompleted() internal view returns (bool) {
        for (uint256 i = 0; i < milestoneIds.length; i++) {
            if (!milestones[milestoneIds[i]].completed || !milestones[milestoneIds[i]].verified) {
                return false;
            }
        }
        return true;
    }

    function setMilestonePercentage(uint256 milestone, uint256 percentage) public onlyBuilder {
        require(milestone > 0 && percentage > 0 && percentage <= 100, "Invalid milestone or percentage");
        milestonePercentages[milestone] = percentage;
    }

    function releaseFunds() internal {
        uint256 totalReleasedAmount = 0;
        
        for (uint256 i = 0; i < milestoneIds.length; i++) {
            uint256 milestoneId = milestoneIds[i];
            if (milestones[milestoneId].completed && milestones[milestoneId].verified) {
                uint256 percentage = milestonePercentages[milestoneId];
                uint256 releaseAmount = totalAmount * percentage / 100;
                totalReleasedAmount += releaseAmount;
            }
        }

        require(paymentToken.transfer(builderAddress, totalReleasedAmount), "Funds release failed");
    }

    function releaseFinalPayment() internal {
        uint256 finalPayment = totalAmount - depositAmount;
        require(paymentToken.transfer(builderAddress, finalPayment), "Final payment failed");
    }
}