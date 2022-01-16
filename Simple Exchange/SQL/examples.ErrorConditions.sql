--Error conditions, if these exists it's an error condition
--Order_Book should only contain live orders

--If there are crosses, there shouldn't be any on the order_book
SELECT b.order_pk,b.is_bid,b.price,b.user_id,b.quantity,
s.order_pk,s.is_bid,s.price,s.quantity,s.user_id
FROM exchg.[order] b JOIN exchg.[order_book] bb on b.order_pk = bb.order_id AND b.is_bid = 1
JOIN exchg.[order] s on b.instrument_id = s.instrument_id AND s.is_bid = 0
JOIN exchg.[order_book] sb on s.order_pk = sb.order_id
WHERE b.price >= s.price

--Currenty Quantity should always be less than order quantity
SELECT * FROM exchg.[order_book] ob join exchg.[order] o on ob.order_id = o.order_pk
WHERE ob.current_qty > o.quantity

--Order_Book can only contain live orders
SELECT * FROM exchg.[order_book] ob join exchg.[order] o on ob.order_id = o.order_pk
WHERE o.is_canceled = 1

--Live orders not on the order_book
SELECT * FROM exchg.[order_book] ob right outer join exchg.[order] o on ob.order_id = o.order_pk
WHERE ob.order_id is null AND o.is_canceled = 0 AND o.is_filled = 0

--Crossed orders that are not on the order_book
SELECT b.order_pk,b.is_bid,b.price,b.user_id,b.quantity,
s.order_pk,s.is_bid,s.price,s.quantity,s.user_id
FROM exchg.[order] b 
JOIN exchg.[order] s on b.instrument_id = s.instrument_id AND s.is_bid = 0
WHERE b.price >= s.price
	AND b.is_bid = 1
	AND b.is_filled = 0
	AND b.is_canceled = 0
	AND s.is_filled = 0
	AND s.is_canceled = 0
