import { LightningElement } from 'lwc';

export default class ECartHeader extends LightningElement {
    cartItemCount = 0;

    handleCartClick() {
        // Navigate to cart page or show cart modal
        console.log('Cart clicked');
    }
}