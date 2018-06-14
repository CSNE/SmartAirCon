output_lines=[] # 출력할 줄 저장
a=1        #각종 변수들
b=-5
k=1
x_last=0
y_last=0
with open("input.txt","r") as f:   #파일 읽기
    input_str=f.read()  
input_lines=input_str.split("\n")  #각 줄로 나눔
input_lines_split=[i.split(" ") for i in input_lines] #각 줄을 공백따라 또 나눔
for line in input_lines_split: #한줄씩 loop
    if line[0]=="m": #Manual
        x_current=float(line[1]) #현재온도. X
        y_current=float(line[2]) #목표온도. Y
        a_1=(y_current-y_last)/(x_current-x_last) #a1 계산
        b_1=y_current-a_1*x_current #b1
        a=(1-k)*a+k*a_1 #a_new 계산. 바로 a에 대입.
        b=(1-k)*b+k*b_1 #b_new 계산.
        k=max(k-0.1,0.1) #k를 0.1 감소. 0.1보다 작아지면 0.1 그대로.
        output_lines.append(str(round(y_current))) #y_current를 그대로 출력.
    elif line[0]=="a": #Automatic
        x=float(line[1]) #현재온도를 X로 가져옴
        y=a*x+b #지금 있는 a,b로 Y=목표온도 계산
        output_lines.append(str(round(y))) #Y 출력.
    else: #뭐야이건
        raise Exception("wut")
with open("output_python.txt","w") as f: #파일에 출력
    f.write("\n".join(output_lines))
