class MoveZeroes(object):
    def moveZeroes(self,nums):
        """
        :type nums:List[int]
        :rtype: None
        """

        length = len(nums)
        if(length==1):
            return

        storageLength = length
        for i in range(0,length):
            if(nums[i]==0):
                nonZeroIdx = self.findNonZeroIdx(nums,i+1,storageLength)
                numZeroes = nonZeroIdx - i
                if(nonZeroIdx >= 0):
                    self.copySubArray(nums,i,nonZeroIdx,storageLength-nonZeroIdx)
                    storageLength = storageLength - numZeroes
            if(i>=storageLength):
                nums[i]=0

    def copySubArray(self,nums,writeStart,readStart,length):
        for i in range(0,length):
            nums[writeStart] = nums[readStart+i]
            writeStart = writeStart+1

    def findNonZeroIdx(self,nums,startIdx,lastIdx):
        for i in range(startIdx,lastIdx):
            if(nums[i]!=0):
                return i
        return -1

#Input: nums = [3,1,2,4]
#Output: [2,4,3,1]
#Explanation: The outputs [4,2,3,1], [2,4,1,3], and [4,2,1,3] would also be accepted.
class SortArrayByParity(object):
    def sortArrayByParity(self,nums):
        """
        :type nums:List[int]
        :rtype: List[int]
        """
        #simple bubble sort
        
        evenIdx = 0
        oddIdx = len(nums)-1
        while evenIdx < oddIdx:
            if(nums[evenIdx]%2==0):#move the evenIdx up as long as we see evens at the start
                evenIdx = evenIdx+1
            else:#found an odd number on evenIdx
                #go find an even number from the other end
                while nums[oddIdx] % 2 != 0 and oddIdx > evenIdx:
                    oddIdx = oddIdx - 1
                
                #Swap the two
                temp = nums[oddIdx]
                nums[oddIdx] = nums[evenIdx]
                nums[evenIdx] = temp
                #increment and decrement both index
                oddIdx = oddIdx - 1
                evenIdx = evenIdx + 1

        return nums

class FindMedianSortedArrays(object):
    def findMedianSortedArrays(self, nums1, nums2):
        """
        :type nums1: List[int]
        :type nums2: List[int]
        :rtype: float
        """
        nums = nums1 + nums2
        nums.sort()
        return self.returnMedianSorted(nums)
    
    def returnMedianSorted(self,nums):
        length = len(nums)
        if length % 2 != 0:
            return nums[length//2]#// operator is division with a floor, similar to integer division in other languages
        else:
            return float(nums[length//2]+nums[length//2-1])/2.0


