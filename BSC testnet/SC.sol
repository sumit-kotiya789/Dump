// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITRC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract MyToken is ITRC20 {
    string public name = "TornToken";
    string public symbol = "TORNT";
    uint8 public decimals = 18;
    uint256 private _totalSupply;

    address public owner;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call");
        _;
    }

    constructor() {
        owner = msg.sender;
        _mint(msg.sender, 1000000 * 10 ** uint256(decimals)); // Initial supply: 1 million
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner_, address spender) public view override returns (uint256) {
        return _allowances[owner_][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    // INTERNAL TRANSFER
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "Invalid sender");
        require(recipient != address(0), "Invalid recipient");
        require(_balances[sender] >= amount, "Insufficient balance");

        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    // INTERNAL APPROVE
    function _approve(address owner_, address spender, uint256 amount) internal {
        require(owner_ != address(0), "Invalid owner");
        require(spender != address(0), "Invalid spender");

        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }

    // INTERNAL MINT
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "Invalid account");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    // INTERNAL BURN
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "Invalid account");
        require(_balances[account] >= amount, "Burn exceeds balance");

        _balances[account] -= amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    // WRITE FUNCTION: Mint tokens (only owner)
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // WRITE FUNCTION: Burn own tokens
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    // WRITE FUNCTION: Burn from someone using allowance
    function burnFrom(address from, uint256 amount) public {
        uint256 allowed = _allowances[from][msg.sender];
        require(allowed >= amount, "Allowance too low");
        _approve(from, msg.sender, allowed - amount);
        _burn(from, amount);
    }

    // WRITE FUNCTION: Transfer ownership
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid new owner");
        owner = newOwner;
    }
}