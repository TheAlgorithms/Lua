-- first 10 fibbonaci numbers in lua

function fib(n)

	if(n < 2) then
		return n
	else
		return fib(n-1) + fib(n-2)
	end

end

for i = 1,10,1 do 
   print(fib(i))
end
