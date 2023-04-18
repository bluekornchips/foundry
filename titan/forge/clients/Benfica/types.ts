export type Benfica_Packs = {
    pack_id: number
    pack_serial: number
    pack_edition_rid: number
    is_visible: boolean
    is_locked: boolean
    is_sold: boolean
    order_rid: any
    is_opened: boolean
    is_available: boolean
    pack_opened_date: Date
}

export type Benfica_Order_Details = {
    order_id: number
    user_reg_rid: number
    internal_tx_ref: string
    external_tx_ref: string
    middlec_customer_rid: any
    description: string
    pack_edition_rid: number
    no_of_packs: number
    total_value: number
    tx_status: string
    tx_type: any
    customer_ip: string
    browser_agent: string
    created_date: Date
    updated_date: Date
}

export type Benfica_Order = {
    order_details: Benfica_Order_Details
    packs: Benfica_Packs[]
}