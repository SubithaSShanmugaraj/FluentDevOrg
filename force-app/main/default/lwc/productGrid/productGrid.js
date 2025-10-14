import { LightningElement, wire, api } from 'lwc';
import getProducts from '@salesforce/apex/ProductController.getProducts';

export default class ProductGrid extends LightningElement {
    @api maxRecords = 12;
    products = [];
    error;

    @wire(getProducts, { maxRecords: '$maxRecords' })
    wiredProducts({ error, data }) {
        if (data) {
            this.products = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.products = [];
            console.error('Error fetching products:', error);
        }
    }

    get hasProducts() {
        return this.products && this.products.length > 0;
    }

    formatPrice(price) {
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD'
        }).format(price);
    }
}