import numpy as np
from collections.abc import Iterable
from typing import NewType

def quantize(value,bitwidth,mode):
    """
    quantizes a value in the intervall [-1, 1-lsb] with the
    requested bitwidth, where lsb = 2^-(bitwidth-1)

    mode can be trunc ('t') or round ('r')
    """
    lsb = 2**(-(bitwidth-1))
    xq = np.minimum(value,1-lsb)
    xq = np.maximum(-1,xq)

    # quantizing
    if mode == 'f':
        xq = np.floor(xq/lsb)*lsb
    else:
        xq = np.round(xq/lsb)*lsb

    return xq


def quantize2(value,B:int,b:int,mode:str,wrap:bool):
    """
    quantizes a value in the intervall [-2^B, 2^B-lsb] where
    lsb is 2^b, be aware b must be a negative number because its
    the index of the fractional number (same as vhdl syntax e.g. 3 downto -4)

    mode can be trunc ('f') or round ('r')
    """

    if(b>0):
        raise ValueError("fractional part must be zero or less than zero")

    if(B<0):
        raise ValueError("integer part must be zero or greater, for representing the sign")

    lsb = 2**(b)
    xq = value
    # quantizing
    if mode == 'f':
        xq = np.floor(xq/lsb)*lsb
    elif(mode == 'r'):
        xq = np.round(xq/lsb)*lsb
    else:
        raise ValueError("given mode {0} is invalid".format(mode))

    if wrap:
        x = fixed_to_int(xq,B-b+1,-b)
        x = x % 2**(B-b+1)

        if x >= 2**(B-b):
            x = x % 2**(B-b)
            xq = int_to_fixed(2**(B-b)+x,B-b+1,-b)
        else:
            x = x % 2**(B-b)
            xq = int_to_fixed(x,B-b+1,-b)
    else:
        xq = np.minimum(xq,2**B-lsb)
        xq = np.maximum(-2**B,xq)

    return xq
    
    


class fixed_point(object):
    """
    Class for representing fixed point usage
    """

    def __init__(self,value,word_len:int,frac_len:int,mode = 'r', wrap:bool = False):
        """
        Parameters
        ----------
        value: int,float
                Value to store in fractional representation
        word_len : int
                word length for the fractional representation (number of bits)
        frac_len: int
                number of bits used as fractional bits, lsb is then 2**(-frac_len)
        mode: str
                use 'r' for rounding mode and 't' for truncating mode
        wrap: bool
                if false, saturation is used, else wrap around
        """
        if(frac_len>=word_len):
            raise ValueError("Fractional length can't be greater equal than word length, because minimum 1 bit is neccessary for sign")

        self._word_len = word_len
        self._frac_len = frac_len
        self._mode = mode
        self._wrap = wrap
        
        self._value = quantize2(value,self.max_idx,self.min_idx,self._mode,self._wrap)
    
    @property
    def value(self):
        return self._value

    @value.setter
    def value(self,value):
        self._value = quantize2(value,self.max_idx,self.min_idx,self._mode,self._wrap)

    def __add__(self,rhs):
        if(isinstance(rhs,fixed_point)):
            return fixed_point(self._value+rhs._value,self.word_len,self.frac_len,self.mode,self.wrap)
        else:
            return fixed_point(self._value+rhs,self.word_len,self.frac_len,self.mode,self.wrap)
    
    def __sub__(self,rhs):
        if(isinstance(rhs,fixed_point)):
            return fixed_point(self._value-rhs._value,self.word_len,self.frac_len,self.mode,self.wrap)
        else:
            return fixed_point(self._value-rhs,self.word_len,self.frac_len,self.mode,self.wrap)

    def __mul__(self,rhs):
        if(isinstance(rhs,fixed_point)):
            return fixed_point(self._value*rhs._value,self.word_len,self.frac_len,self.mode,self.wrap)
        else:
            return fixed_point(self._value*rhs,self.word_len,self.frac_len,self.mode,self.wrap)
    
    def __truediv__(self,rhs):
        if(isinstance(rhs,fixed_point)):
            return fixed_point(self._value/rhs._value,self.word_len,self.frac_len,self.mode,self.wrap)
        else:
            return fixed_point(self._value/rhs,self.word_len,self.frac_len,self.mode,self.wrap)

    def __lshift__(self, n: int):
        return fixed_point(self._value * 2**n,self.word_len,self.frac_len,self.mode,self.wrap)

    def __rshift__(self, n: int):
        return fixed_point(self._value / 2**n,self.word_len,self.frac_len,self.mode,self.wrap)
    
    def __gt__(self, rhs):
        if(isinstance(rhs,fixed_point)):
            return self._value > rhs._value
        else:
            return self._value > rhs

    def __ge__(self, rhs):
        if(isinstance(rhs,fixed_point)):
            return self._value >= rhs._value
        else:
            return self._value >= rhs

    def __lt__(self, rhs):
        if(isinstance(rhs,fixed_point)):
            return self._value < rhs._value
        else:
            return self._value < rhs

    def __le__(self, rhs):
        if(isinstance(rhs,fixed_point)):
            return self._value <= rhs._value
        else:
            return self._value <= rhs

    def __eq__(self, rhs):
        if(isinstance(rhs,fixed_point)):
            return self._value == rhs._value
        else:
            return self._value == rhs

    def __ne__(self, rhs):
        if(isinstance(rhs,fixed_point)):
            return self._value != rhs._value
        else:
            return self._value != rhs

    def __str__(self):
        return str(self._value)

    def __repr__(self):
        return "fixed_point(%s)" % self._value

    @property
    def word_len(self):
        return self._word_len

    @property
    def integer_bits(self):
        return self._word_len-self._frac_len

    @property
    def frac_len(self):
        return self._frac_len

    @property
    def min_idx(self):
        return -self._frac_len

    @property
    def max_idx(self):
        return (self._word_len-self._frac_len-1)

    @property
    def mode(self):
        return self._mode

    @property
    def wrap(self):
        return self._wrap


def to_fixed_point(value,word_len:int = None,frac_len:int = None, alike:fixed_point = None, mode = 'r', wrap:bool = False):
    """
    converts a list,numpy array,or single number of ints,floats into a list, array of fractional bits
    Parameters
    ----------
    value: float,int, list, numpy.ndarray
    word_len: int
        fractional word length
    frac_len: int
        bits used for fractional representation
    alike: fixed_point
        can be used instead of giving word_len and frac_len
    ...
    """
    if((word_len == None or frac_len == None) and alike == None):
        raise ValueError("some reference or word_length and fractional length must be given")
    if(alike is not None):
        word_len = alike.word_len
        frac_len = alike.frac_len
        mode = alike.mode
        wrap = alike.wrap
    if(isinstance(value,Iterable)):
        arr = []
        for val in value:
            arr.append(fixed_point(val,word_len,frac_len,mode,wrap)) 
    
        if (isinstance(value,np.ndarray)):
            return np.array(arr)
        else:
            return arr

    else:
        return fixed_point(value,word_len,frac_len,mode,wrap)

def from_fixed_point(o):
    """
    converts fixed point into floats (usefull for plotting,...)
    """
    if(isinstance(o,Iterable)):
        arr = []
        for val in o:
            arr.append(from_fixed_point(val))
            #arr.append(val.value)

        if(isinstance(o,np.ndarray)):
            return np.array(arr)
        else:
            return arr
    else:
        return o.value

def single_int_to_fixed(value:int, word_len:int, frac_len:int):
    if(frac_len>= word_len):
        raise ValueError("frac len must be lower than word len")

    value = value % 2**word_len

    if(value >= 2**(word_len-1)):
        fixed_val = (value - 2**(word_len-1)) / 2**(frac_len) - 2**(word_len-frac_len-1)
    else:
        fixed_val = (value - 2**(word_len-1)) / 2**(frac_len) + 2**(word_len-frac_len-1)

    return fixed_val

def int_to_fixed(value, word_len:int, frac_len:int):
    if(isinstance(value,Iterable)):
        arr = []
        if(len(value)==0):
            return arr
        else:
            for val in value:
                int_val = single_int_to_fixed(val,word_len,frac_len)
                arr.append(int_val)
            if(isinstance(value,np.ndarray)):
                return np.array(arr)
            else:
                return arr
    else:
        return single_int_to_fixed(value,word_len,frac_len)

def single_fixed_to_int(value,word_len:int=None, frac_len:int=None):
    if(isinstance(value,fixed_point)):
            word_len = value.word_len
            frac_len = value.frac_len
            value = value.value
    elif(isinstance(value,float) and ((word_len == None) or (frac_len == None))):
        raise TypeError("bitwidth and fraclen must be given")

    if(frac_len>= word_len):
        raise ValueError("frac len must be lower than word len")

    if(value < 0):
        int_val = (value + 2**(word_len-frac_len-1))*2**(frac_len) + 2**(word_len-1)
    else:
        int_val = (value - 2**(word_len-frac_len-1))*2**(frac_len) + 2**(word_len-1)

    return int(int_val)

def fixed_to_int(value, word_len:int=None, frac_len:int=None):
    if(isinstance(value,Iterable)):
        arr = []
        if(len(value)==0):
            return arr
        else:
            for val in value:
                int_val = single_fixed_to_int(val,word_len,frac_len)
                arr.append(int_val)
            if(isinstance(value,np.ndarray)):
                return np.array(arr)
            else:
                return arr
    else:
        return single_fixed_to_int(value,word_len,frac_len)