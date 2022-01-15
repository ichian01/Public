
--If an order exists in order, but not in order_book, then that's a dead order.
--If I store current quantity in order, for partial fills, then that uses more space


--Find crosses
select b.order_pk,b.is_bid,b.price,b.user_id,b.quantity,s.order_pk,s.is_bid,s.price,s.quantity,s.user_id
from exchg.[order] b join exchg.[order] s on b.is_bid = 0 and s.is_bid = 1 and b.instrument_id = s.instrument_id and b.price = s.price