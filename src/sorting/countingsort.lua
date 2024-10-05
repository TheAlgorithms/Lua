function counting_sort(arr, key_function)
     -- If no key_function is provided, use identity function
     key_function = key_function or function(x) return x end

     -- Step 1: Find the range of keys (min_key and max_key)
     local min_key, max_key = math.huge, -math.huge
     for i = 1, #arr do
         local key = key_function(arr[i])
         if key < min_key then
             min_key = key
         end
         if key > max_key then
             max_key = key
         end
     end

     -- Step 2: Initialize the count array
     local count = {}
     for i = min_key, max_key do
         count[i] = 0
     end

      -- Step 3: Count the occurrences of each key. In this case key is same as arr[i]
     for i = 1, #arr do
         local key = key_function(arr[i])
         count[key] = count[key] + 1
     end

     -- Step 4: Compute cumulative counts to get final positions
     for i = min_key + 1, max_key do
         count[i] = count[i] + count[i - 1]
     end

     -- Step 5: Build the output array (in stable order)
     local output = {}
     for i = #arr, 1, -1 do
         local element = arr[i]
         local key = key_function(element)
         output[count[key]] = element
         count[key] = count[key] - 1
     end

     -- Step 6: Copy the output array back to the original array
     for i = 1, #arr do
         arr[i] = output[i]
     end
 end

-- Sample array
local arr = {100, 2, 2, 8, 3, 10000000, 1}

-- Simple usage with identity key function
counting_sort(arr)

-- Print sorted array
for i, v in ipairs(arr) do
    print(v)
end
