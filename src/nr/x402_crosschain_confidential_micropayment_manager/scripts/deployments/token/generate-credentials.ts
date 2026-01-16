import { Fr } from '@aztec/aztec.js/fields';

const secretKey = Fr.random();
const salt = Fr.random();

console.log('\n=====================================');
console.log('Generated Aztec Account Credentials:');
console.log('=====================================');
console.log('Secret Key:', secretKey.toString());
console.log('Salt:', salt.toString());
console.log('=====================================');
console.log('IMPORTANT: Save these values securely!');
console.log('=====================================\n');
