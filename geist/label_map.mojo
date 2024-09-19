from collections import Optional

@value
struct LabelMap[Type: CollectionElement]:
    var _data: List[Type]
    var _lbl2idx: List[Int]
    var _idx2lbl: List[Int]

    fn __init__(inout self, *, initial_capacity: Int = 512):
        self._data = List[Type](capacity=initial_capacity)
        self._lbl2idx = List[Int](capacity=initial_capacity)
        self._idx2lbl = List[Int](capacity=initial_capacity)

    fn __getitem__(ref [_]self, lbl: Int) -> Optional[Reference[Type, __lifetime_of(self)]]:
        var idx = self._lbl2idx[lbl]
        if idx < 0:
            return None
        else:
            return Reference[Type, __lifetime_of(self)](self._data[idx])

    fn __setitem__(inout self, lbl: Int, owned item: Optional[Type]):
        if item:
            if lbl >= len(self._lbl2idx):
                for _ in range(len(self._lbl2idx) - lbl):
                    self._lbl2idx += -1
                self._lbl2idx += len(self._data)
                self._data += item.unsafe_take()
                self._idx2lbl += lbl 
            else:
                self._data[self._lbl2idx[lbl]] = item.unsafe_take()
        elif lbl < len(self._lbl2idx) and self._lbl2idx[lbl] >= 0:
            self._data[self._lbl2idx[lbl]] = self._data.pop()
            self._lbl2idx[lbl] = -1
            self._idx2lbl[self._lbl2idx[lbl]] = self._idx2lbl.pop()

