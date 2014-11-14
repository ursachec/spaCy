cdef void begin_entity(State* s, label):
    s.j += 1
    s.ents[s.j].start = s.i
    s.ents[s.j].tag = label
    s.ents[s.j].end = s.i + 1


cdef void end_entity(State* s):
    s.ents[s.j].end = s.i + 1


cdef State* init_state(Pool mem, int sent_length) except NULL:
    s = <State*>mem.alloc(1, sizeof(State))
    s.ents = <Entity*>mem.alloc(sent_length, sizeof(Entity))
    s.tags = <int*>mem.alloc(sent_length, sizeof(int))
    s.length = sent_length


cdef bint entity_is_open(State *s):
    return s.ents[s.j].start != 0


cdef bint entity_is_sunk(State *s, Move* golds):
    if not entity_is_open(s):
        return False

    cdef Entity* ent = &s.ents[s.j]
    cdef Move* gold = &golds[ent.start]
    if gold.action != BEGIN and gold.action != UNIT:
        return True
    elif gold.label != ent.label:
        return True
    else:
        return False


cdef int copy_state(Pool mem, State* dest, State* source) except -1:
    '''Copy state source into state dest.'''
    if source.length > dest.length:
        dest.ents = <Entity*>mem.realloc(dest.ents, source.length * sizeof(Entity))
        dest.tags = <int*>mem.realloc(dest.tags, source.length * sizeof(int))
    memcpy(dest.ents, source.ents, source.length * sizeof(Entity))
    memcpy(dest.tags, source.tags, source.length * sizeof(int))
    dest.length = source.length
    dest.i = source.i
    dest.j = source.j
    dest.curr = source.curr



