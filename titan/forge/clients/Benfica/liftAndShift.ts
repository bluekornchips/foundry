const fs = require('fs');

import { Benfica_Order, Benfica_Order_Details, Benfica_Packs } from './types';
import Ducky from '../../../utility/logging/ducky';

const liftAndShift = async () => {
    let packs: Benfica_Packs[] = await readFromFile("packs");
    let orderDetails: Benfica_Order_Details[] = await readFromFile("order_details");
    // Remove the orderDetails that have a tx_status not of "COMPLETE"
    orderDetails = orderDetails.filter((orderDetail: Benfica_Order_Details) => {
        if (orderDetail.tx_status === "COMPLETE") {
            return true;
        }
        return false;
    });
    Ducky.Debug(__filename, "liftAndShift", `Completed Orders: ${orderDetails.length}`);
    const orders: Benfica_Order[] = [];

    // Join packs with orderDetails on packs.order_rid === orderDetails.order_id
    orderDetails.map((orderDetail: Benfica_Order_Details) => {
        const packsForOrder = packs.filter((pack: Benfica_Packs) => {
            return pack.order_rid === orderDetail.order_id;
        });
        if (packsForOrder.length !== 0) {
            orders.push({
                order_details: orderDetail,
                packs: packsForOrder
            });
        }
    });
    Ducky.Debug(__filename, "liftAndShift", `Orders: ${orders.length}`);


    // // Sort the packs by pack_opened_date and then remove the nulls
    // const sortedPacks = packs.sort((a: Benfica_Packs, b: Benfica_Packs) => {
    //     return a.pack_opened_date > b.pack_opened_date ? 1 : -1;
    // }).filter((pack: Benfica_Packs) => {
    //     return pack.pack_opened_date !== null;
    // });

}

const readFromFile = async (tablename: string) => {
    try {
        const file = `${__dirname}/${tablename}.json`
        const readFile = fs.readFileSync(file, 'utf8');
        const loaded = JSON.parse(readFile)[tablename];
        Ducky.Debug(__filename, "liftAndShift", `Loaded ${tablename}: ${loaded.length}`);
        return loaded;
    } catch (error: any) {
        Ducky.Error(__filename, "liftAndShift", `Error: ${error.message}`);
    }
}

export default liftAndShift