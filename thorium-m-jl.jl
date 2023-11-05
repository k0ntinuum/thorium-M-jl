using LinearAlgebra
using Printf

str(v,s)  = join(map(i -> i ? "|"*s : "0"*s , v))
print_key(k) = for i in 1:size(k)[begin] print(str(k[i,:]," "),"\n") end
print_vec(v) = print(str(v,""),"\n")
key(n) = rand(Bool,n,n)

spin_row(k,i) = circshift(k[i,:], k[i,i]  + 1)
spin_col(k,i) = circshift(k[:,i], k[i,i]  + 1)


rgb(r,g,b) =  "\e[38;2;$(r);$(g);$(b)m"

red() = rgb(255,0,0);yellow() = rgb(255,255,0);white() = rgb(255,255,255);gray(h) = rgb(h,h,h)
blue() = rgb(0,0,255);


function encode(p,q)
    k = copy(q)
    n = size(k)[begin]
    c = Bool[]
    for i in eachindex(p)
        push!(c,Bool((tr(k) + p[i])%2))
        if  Bool(p[i]) 
            k[mod1(i,n),:] = spin_row(k,mod1(i,n))
        else 
            k[:,mod1(i,n)] = spin_col(k,mod1(i,n))
        end
    end
    c
end

function decode(c,q)
    k = copy(q)
    n = size(k)[begin]
    p = Bool[]
    for i in eachindex(c)
        push!(p,Bool((tr(k) + c[i])%2))
        if  Bool(p[i]) 
            k[mod1(i,n),:] = spin_row(k,mod1(i,n))
        else 
            k[:,mod1(i,n)] = spin_col(k,mod1(i,n))
        end
    end
    p
end

function autospin(q,c)
    k = copy(q)
    n = size(k)[begin]
    for i in 1:n Bool(q[i,c]) ? k[i,:] = spin_row(k,i) : k[:,i] = spin_col(k,i) end
    k
end

function encrypt(p, q, r)
    for i in 1:r
        k = autospin(q, mod1(i,n))
        p = encode(p,k)
        p = reverse(p)
    end
    p
end

function decrypt(p, q, r)
    for i in 1:r
        k = autospin(q,mod1(r + 1 - i,n))
        p = reverse(p)
        p = decode(p,k)
    end
    p
end

function demo()
    n = 32
    r = n
    k = key(n)
    t = 32
    w = 16
    print(white(),"k =\n", gray(150))
    print_key(k)
    print("\n",white(),"r = \n",gray(150),r,"\n\n")
    for i in 1:w
    	p = rand(Bool,t)
        print(white(),"f( ", red(), str(p,""), white()," ) = ")
        c  = encrypt(p,k,r)
        print(yellow(),str(c,""), "    ")
        e = p .== c
        print(gray(100),str(e,""), " \n")
        d  = decrypt(c,k,r)
        if p != d @printf "ERROR" end 	
    end
    print(white())
end

function long_demo()
    print(white(),"k =\n", gray(150))
    print_key(k)
    print("\n",white(),"r = \n",gray(150),r,"\n\n")
    for i in 1:w
    	p = rand(Bool,t)
        print( red(), str(p,""), "\n")
        c  = encrypt(p,k,r)
        print( yellow(), str(c,""), "\n")
        e = p .!= c
        print(gray(100),str(e,""), " \n\n")
        d  = decrypt(c,k,r)
        if p != d @printf "\nERROR\n" end 	
    end
    print(white())
end


