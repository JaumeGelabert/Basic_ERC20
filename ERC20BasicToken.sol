// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import "./SafeMath.sol";

//Interface de nuestro token ERC20
//Aqui pondremos todos los métodos que necesitemos
interface IERC20{
    //Devuelve la cantidad de tokens en existencia
    function TotalSupply() external view returns(uint256);

    //Devuelve la cantidad de tokens para una dirección indicada por parámetro
    function BalanceOf(address _account) external view returns(uint256);

    //Devuelve el numero de token que el spender podrá gastar en nombre del propietario (owner)
    function allowance(address owner, address spender) external view returns(uint256);

    //Devuelve un valor booleano resultado de la operación indicada
    function transfer(address recipient, uint256 amount) external returns(bool);

    //Devuelve un valor booleano con el resultado de la operación de gasto
    function approve(address spender, uint256 amount) external returns(bool);

    //Devuelve un valor booleano con el resultado de la operación de paso de una cantidad de tokens usando el método allowance() declarado previamente. 
    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);

    //Evento que se debe emitir cuando una cantida de tokens pase de un origen a un destino
    //Todo el mundo será notificado para evitar 'zonas oscuras'
    event Transfer(address indexed from, address indexed to, uint256 value);

    //Evento que se debe emitir cuando se establece una asignación con el método allowance() previamente creado
    event Approval(address indexed owner, address indexed spender, uint256 value);

}

//Implementación de las funciones del token ERC20
contract ERC20Basic is IERC20{

    //Nombre de nuestra moenda
    string public constant name = "ERC20ENMETUS";
    string public constant symbol = "ERC";
    uint8 public constant decimals = 18;

    event TransferEvent(address indexed from, address indexed to, uint256 tokens);
    event ApprovalEvent(address indexed owner, address indexed spender, uint256 tokens);

    //Lo que conseguimos es que todos los resultados 'uint256' se pasarán por la librerira declarada para evitar posibles errores de overflow. 
    using SafeMath for uint256;

    //A cada direccion le va a corresponeder un numero determinado de tokens
    mapping(address=>uint) balances;

    //A cada direccion le corresponde un mapping de direccion a uint
    mapping(address => mapping(address => uint)) allowed;

    //Total Supply
    uint256 totalSupply_;

    constructor (uint256 initialSupply){
        totalSupply_ = initialSupply;
        balances[msg.sender] = totalSupply_;
    }


    function TotalSupply() public override view returns(uint256){
        return(totalSupply_);
    }

    function increaseTotalSupply(uint newTokensAmount) public {
        totalSupply_ += newTokensAmount;
        balances[msg.sender] += newTokensAmount;
    }

    function BalanceOf(address _tokenOwner) public override view returns(uint256){
        return(balances[_tokenOwner]);
    }

    function allowance(address owner, address delegate) public override view returns(uint256){
        return(allowed[owner][delegate]);
    }

    function transfer(address recipient, uint256 numTokens) public override returns(bool){
        //Comprobamos si se puede realizar la operación
        require(numTokens <= balances[msg.sender], "No tienes suficientes fondos en tu cuenta!");
        //Realizamos la operación de manera segura mediante la libreria SafeMath
        //Primero debemos restar la cantidad y luego añadirlo a la otra cuenta
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[recipient] = balances[recipient].add(numTokens);
        emit TransferEvent(msg.sender, recipient, numTokens);
        //Si la transacción se ha completado correctamente, se emitirá 'true'
        return true;
    }

    //El delegate es la persona que gastará tokens en mi nombre
    function approve(address delegate, uint256 numTokens) public override returns(bool){
        //Mediante la siguiente linea, delegamos a la dirección 'delegate' la cantidad de 'numTokens'
        allowed[msg.sender][delegate] = numTokens;
        emit ApprovalEvent(msg.sender, delegate, numTokens);
        return true;
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns(bool){
        require(numTokens <= balances[owner], "No tienes suficients fondos!");
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit TransferEvent(owner, buyer, numTokens);
        return true;
    }
}