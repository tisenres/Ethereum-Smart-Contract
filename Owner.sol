// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

contract Owner {
    uint public receiversNumber;
    uint public bank;
    address public owner;

    struct Receiver {
        string name;
        uint256 birthday;
        bool alreadyGotMoney;
        bool exitst;
    }

    address[] public arrReceivers;

    mapping(address => Receiver) public receivers;

    constructor () {
        owner = msg.sender;
        receiversNumber = 0;
    }

    modifier onlyOwner() {
        require (msg.sender == owner, "You are not owner");
        _;
    }

    function addReceiver (
        address walletAddress,
        string memory name,
        uint256 birthday
        ) public onlyOwner
    {
        require (birthday > 0, "Something is wrong with birhday!");
        require (receivers[walletAddress].exitst == false, "This receiver already exists!");

        receivers[walletAddress] = (
            Receiver(name, birthday, false, true)
        );

        arrReceivers.push(walletAddress);
        receiversNumber++;

        emit NewReceiver(walletAddress, name, birthday);
    }

    function deposit() external payable {
        bank += msg.value;
    }

    function balanceOf() public view returns (uint256) {
        return address(this).balance;
    }

    function withdraw() public {
        address payable walletAddress = payable(msg.sender);

        require(
            receivers[walletAddress].exitst == true,
            "There is no such grandchild!"
        );

        require(
            block.timestamp >= receivers[walletAddress].birthday,
            "Birthday hasn't arrived yet!"
        );

        require(
            receivers[walletAddress].alreadyGotMoney == false,
            "You have already recieved money!"
        );

        uint256 amount = bank / receiversNumber;
        receivers[walletAddress].alreadyGotMoney = true;

        (bool success, ) = walletAddress.call {value: amount} ("");
        require(success);

        emit GotMoney(walletAddress);
    }

    function readReceiversArray(uint cursor, uint length) public view returns(address[] memory) {
        address[] memory array = new address[](length);
        uint counter = 0;

        for (uint i = cursor; i < cursor + length; i++) {
            array[counter] = arrReceivers[i];
            counter++;
        }

        return array;
    }

    event NewReceiver(address indexed walletAddress, string name, uint256 birthday);
    event GotMoney(address indexed walletAddress);
}
