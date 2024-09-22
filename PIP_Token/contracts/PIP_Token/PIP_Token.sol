// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interface ERC-20 conforme o padrão
interface IToken {
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract PIP_Tokens is IToken {
    string public constant name = "PIP_Token";  // Nome do Token
    string public constant symbol = "PIP";      // Símbolo do Token
    uint8 public constant decimals = 18;        // Decimais padrão (18)
    uint256 public constant _initialSupply = 1000000 * (10 ** uint256(decimals)); // Suprimento inicial com decimais

    mapping(address => uint256) private _balances;   // Mapeamento para saldos
    mapping(address => mapping(address => uint256)) private _allowed;  // Mapeamento para permissões (allowance)

    uint256 private _totalSupply; // Variável de estado para o total de tokens

    // Construtor que aloca o suprimento inicial ao criador do contrato (deployer)
    constructor() {
        _totalSupply = _initialSupply; // Define o total de tokens
        _balances[msg.sender] = _totalSupply;  // Aloca todos os tokens ao deployer
        emit Transfer(address(0), msg.sender, _totalSupply); // Emite evento de transferência inicial
    }

    // Retorna o total de tokens emitidos
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    // Retorna o saldo de um endereço específico
    function balanceOf(address _owner) public view override returns (uint256) {
        return _balances[_owner];
    }

    // Função de transferência para enviar tokens a outro endereço
    function transfer(address _to, uint256 _value) public override returns (bool success) {
        require(_balances[msg.sender] >= _value, "Saldo insuficiente");
        _balances[msg.sender] -= _value;
        _balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // Transferência de tokens a partir de um endereço aprovado
    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success) {
        uint256 _allowance = _allowed[_from][msg.sender];
        require(_balances[_from] >= _value && _allowance >= _value, "Saldo insuficiente ou nao autorizado");
        _balances[_from] -= _value;
        _balances[_to] += _value;
        if (_allowance < type(uint256).max) {
            _allowed[_from][msg.sender] -= _value;
        }
        emit Transfer(_from, _to, _value);
        return true;
    }

    // Aprova um endereço para gastar tokens em nome do chamador
    function approve(address _spender, uint256 _value) public override returns (bool success) {
        _allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // Retorna a quantidade permitida para um endereço gastar em nome de outro
    function allowance(address _owner, address _spender) public view override returns (uint256) {
        return _allowed[_owner][_spender];
    }
}
