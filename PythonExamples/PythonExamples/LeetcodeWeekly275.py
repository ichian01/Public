
class Solution:
    def checkValid(self, matrix: list[list[int]]) -> bool:
        n = len(matrix)

        #zip aggregates multiple iterable and returns list of tuples
        #languages = ['Java', 'Python', 'JavaScript']
        #versions = [14, 3, 6]
        #result = zip(languages, versions)
        #print(list(result))
        # Output: [('Java', 14), ('Python', 3), ('JavaScript', 6)]
        #set creates a non repeating, distinct iterable.  Such as a list, tuple, or dictionary.
        for row, col in zip(matrix, zip(*matrix)):
            if len(set(row)) != n or len(set(col)) != n:#calling set creates distinct, so check the length of the set vs n
                return False
        return True
        #rowCheck = {}
        #colCheck = []
        #for row in range(0,n):
            #rowCheck.clear()
            #for col in range(0,n):
                #if(len(colCheck<n)):
                    #colCheck.append({})

    #given a circular array nums, min number of swaps to group all the 1's together.
    def minSwaps(self,nums:list[int])->int:
        swapCount = 0
        #are the 1's grouped together?

        return 0
    #examples
    #[0,1,0,1,1,0,0] 1 swap
    #[0,1,1,1,0,0,1,1,0] 2 swaps
    #[1,1,0,0,1] #0 swaps because it's circular array and the 1's are together
    #[1,1,0,0,0,1,0,0,0,1] 1 swap, just have to move the lone 1 together.
    #[1,1,0,0,0,0,1,1,0,1] 1 swap, just have to move index item 1 or 7 to the 0 next to the end to connect.


matrix = [[1,2,3],[3,1,2],[2,3,1]]
print(*matrix)
print(list(zip(*matrix)))
print(list(zip(matrix,zip(*matrix))))
c = Solution()
print(c.checkValid(matrix))
#Output: true
#Explanation: In this case, n = 3, and every row and column contains the numbers 1, 2, and 3. Hence, we return true.

matrix = [[1,3,3,5],[3,1,5,3],[5,3,3,1],[3,5,1,3]]
c = Solution()
print(c.checkValid(matrix))
#Should return false, this example catches the "checksum" method.  checking sum of each row and column against n/2*(n+1)

