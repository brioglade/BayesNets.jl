function Base.rand(b::BayesNet)
  ordering = topological_sort_by_dfs(b.dag)
  a = Assignment()
  for name in b.names[ordering]
    a[name] = rand(cpd(b, name), a)
  end
  a
end

function randTable(b::BayesNet; numSamples=10, consistentWith=Assignment())
  ordering = topological_sort_by_dfs(b.dag)
  t = [n => Any[] for n in b.names]
  a = Assignment()
  for i = 1:numSamples
    for name in b.names[ordering]
      a[name] = rand(cpd(b, name), a)
    end
    if consistent(a, consistentWith)
      for name in b.names[ordering]
        push!(t[name], a[name])
      end
    end
  end
  DataFrame(t)
end

function randTableWeighted(b::BayesNet; numSamples=10, consistentWith=Assignment())
    ordering = topological_sort_by_dfs(b.dag)
    t = [n => Any[] for n in b.names]
    w = ones(numSamples)
    a = Assignment()
    for i = 1:numSamples
        for name in b.names[ordering]
            if haskey(consistentWith, name)
                a[name] = consistentWith[name]
                w[i] *= pdf(cpd(b, name), a)(a[name])
            else
                a[name] = rand(cpd(b, name), a)
            end
            push!(t[name], a[name])
        end
    end
    t[:p] = w / sum(w)
    DataFrame(t)
end

# generate a random dictionary of Bernoulli parameters
# given some number of parents
function randBernoulliDict(numParents::Integer)
    dims = ntuple(numParents, i->2)
    [[ind2sub(dims, i)...] .- 1 => round(1+rand()*98)/100 for i = 1:prod(dims)]
end
