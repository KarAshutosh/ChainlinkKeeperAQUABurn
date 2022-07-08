// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract AQUABurn is KeeperCompatibleInterface, Ownable 
{
    
    uint public interval;
    uint public lastTimeStamp;
    address public immutable burnAddress = 0x000000000000000000000000000000000000dEaD;
    address tokenAddress;

    uint public burnAmount;

    event UpdatedInterval(uint, uint);
    event UpdatedBurnAmount(uint, uint);
    event Withdrew(address, uint);
    event UpdatedTokenAddress(address, address);
    event balanceSufficient(bool);

    constructor(uint _updateInterval) 
    {
        interval = _updateInterval;
        lastTimeStamp = block.timestamp;
        burnAmount = 0;
        tokenAddress = 0x72B7D61E8fC8cF971960DD9cfA59B8C829D91991;
    }

    function updateInterval(uint _updateInterval) public onlyOwner 
    {
        uint oldInterval = interval;
        interval = _updateInterval;
        emit UpdatedInterval(oldInterval, interval);
        
    }

    function updateBurnAmount(uint _updateBurnAmount) public onlyOwner
    {
        uint oldBurnAmount = burnAmount;
        burnAmount = _updateBurnAmount;
        emit UpdatedBurnAmount(oldBurnAmount, burnAmount);
    }

    function updateTokenAddress(address _updateTokenAddress) public onlyOwner
    {
        address oldTokenAddress = tokenAddress;
        tokenAddress = _updateTokenAddress;
        emit UpdatedTokenAddress(oldTokenAddress, tokenAddress);
    }

    function withdrawAll(address _tokenAddress) external payable onlyOwner 
    {
        IERC20 token = IERC20(_tokenAddress);
        uint amount = token.balanceOf(address(this));
        address _owner = owner();
        token.transfer(_owner, amount);
        emit Withdrew(_tokenAddress, amount);
    } 

    function getContractBalance() public view returns(uint) 
    {
        IERC20 token = IERC20(tokenAddress);
        uint balance_ = token.balanceOf(address(this));
        return balance_;
    }

     function getMyBalance() public view returns(uint) 
    {
        IERC20 token = IERC20(tokenAddress);
        uint balance_ = token.balanceOf(msg.sender);
        return balance_;
    }
        
    //function deposit(uint _amount) public payable
    //{
    //    IERC20 token = IERC20(tokenAddress);
    //    require(_amount <= token.balanceOf(msg.sender), "you don't have enough balance.");
    //    token.approve(address(this), _amount);
    //    token.transferFrom(msg.sender, address(this), _amount);
    //}

    function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory /* performData */) 
    {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
    }

    function performUpkeep(bytes calldata /* performData */) external override 
    {

        IERC20 token = IERC20(tokenAddress);
        uint balance = token.balanceOf(address(this));

        if ((block.timestamp - lastTimeStamp) > interval && (balance >= burnAmount)) 
        {
            emit balanceSufficient(balance >= burnAmount);
            token.transfer(burnAddress, burnAmount);
            lastTimeStamp = block.timestamp;
        }
    }
}
