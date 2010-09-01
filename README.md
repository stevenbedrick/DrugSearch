h1. ReadMe: DrugSearch
----

This is a small Ruby class that (at one point, anyway) was able to connect to the US National Library of Medicine's [MedlinePlus](http://www.nlm.nih.gov/medlineplus/) service, lookup drugs, and return lists of their side effects. At the moment, most of its unit tests fail-- probably due to site changes on the NLM's side. However, I suspect that, with relatively minor fixes, an interested party could get it working again in quite quickly. This code was used in the system described in [this paper](http://www.ncbi.nlm.nih.gov/pubmed/20351818).

I make no claims about the quality of the code: it was "good enough for me", but that ain't saying much. As such, it's released under the CRAPL license, with all that entails, specifically clauses 2.5 and 3.3.

The included RSpec file should make it easier to get running again- the tests might be a little out of date, but they should  be easy to update as well.