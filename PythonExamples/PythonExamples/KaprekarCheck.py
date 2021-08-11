
def SortDigits(num, ascending=True):
    str_num = str(num).zfill(4)
    return ''.join(sorted(str_num,reverse=not ascending))

def FindKapreka(num):
    result = num
    for n in range(10):
        larger = int(SortDigits(result,False))
        smaller = int(SortDigits(result,True))
        result = larger - smaller

    if result == 6174:
        return True
    else :
        return False


#print(FindKapreka(6174))

kapreka = [FindKapreka(num) for num in range(0,10000)]

not_kapreka = []
for index,result in enumerate(kapreka):
    if result == False :
        not_kapreka.append(index)

print(not_kapreka)