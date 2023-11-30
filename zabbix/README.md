# ZABBIX INSTALL Play Book
> * 목차
> > 1. 설치 테스트 환경 
> > 2. 설치방법
> > 3. 참고사항

## 1. 설치 환경
> * OS : 22.04
> * Web Server: nginx
> * Zabbix: 6.4
> * DBMS : mariadb


## 2. 설치 방법
> ### repo 설정 
>> 1. ansible 
  ``` install.yaml 수정
    {{ passwd }} , {{ port }} {{ domain }} 부분을 고정값으로 변경 후 
    ansible-playbook install.yaml -k -K 실행
   ```

>>2. ansible tower
```
템플릿 작성시 하단 변수 항목에  (아래 값들은 예제 입니다)
passwd: zabbix
port: 8080
domain: localhost

입력 후 템플릿 실행
```
>>3. 참고사항
>* 해당 스크립트는 로컬에 MYSQL을 설치하는 방식으로 작성되어있으며 실행될 떄 마다 DB를 초기화 하고 재구성합니다
>* 해당 내용을 숙지 후 사용바랍니다 