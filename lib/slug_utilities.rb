class SlugUtilities
  def base_from_slug(slug)
    return slug =~ /\A(.*)-([0-9]+)\Z/ ? slug.slice(/\A(.*)-([0-9]+)\Z/, 1) : slug
  end

  def id_from_slug(slug)
    return slug if slug =~ /\A[0-9]+\Z/
    return slug =~ /\A(.*)-([0-9]+)\Z/ ? slug.slice(/\A(.*)-([0-9]+)\Z/, 2) : nil
  end
end
