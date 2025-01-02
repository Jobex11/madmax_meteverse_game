// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Madmax {
    mapping (address => uint256) private _balances;
    address private _owner;
    
    mapping (address => mapping (address => uint256)) private _allowances;
    
    uint256 private _totalSupply = 1000000000000 * 10**18;
    
    uint private _tax = 0;
    
    string private _name;
    string private _symbol;
    uint8 private _decimals = 18;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _owner = msg.sender;
        _mint(_owner, _totalSupply);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function mint(address to, uint amount) external {
        require(msg.sender == _owner, "Only owner");
        _mint(to, amount);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) public {
        require(msg.sender == _owner, "Only owner can transfer ownership");
        require(newOwner != address(0), "New owner cannot be zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function handleTransfer(address sender, address recipient, uint amount) internal returns (bool) {
        require(_balances[sender] >= amount, "Insufficient Amount");

        uint256 feeTransfer = (amount * _tax) / 100;
        uint256 amountAfterFee = amount - feeTransfer;

        _transfer(sender, recipient, amountAfterFee);
        _burn(sender, feeTransfer);
        return true;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        return handleTransfer(msg.sender, recipient, amount);
    }

    function allowance(address sender, address spender) public view returns (uint256) {
        return _allowances[sender][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function setTax(uint tax) external returns (bool) {
        require(msg.sender == _owner, "Only owner can set tax");
        _tax = tax;
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(amount <= _allowances[sender][msg.sender], "Transfer amount cannot exceed allowance");
        _allowances[sender][msg.sender] -= amount;
        handleTransfer(sender, recipient, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(subtractedValue <= _allowances[msg.sender][spender], "Decreased allowance below zero");
        _approve(msg.sender, spender, _allowances[msg.sender][spender] - subtractedValue);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address sender, address spender, uint256 amount) internal {
        require(sender != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[sender][spender] = amount;
        emit Approval(sender, spender, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        _balances[account] -= amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }
}

//0xFA83c7De4A791b7528106672C53aE88f92ef6608