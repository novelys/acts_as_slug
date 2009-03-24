class SlugUtilities
  def base_from_slug(slug)
    return current_slug =~ /\A(.*)-([0-9]+)\Z/ ? current_slug.slice(/\A(.*)-([0-9]+)\Z/, 1) : current_slug
  end

  def id_from_slug(slug)
    return current_slug if current_slug =~ /\A[0-9]+\Z/
    return current_slug =~ /\A(.*)-([0-9]+)\Z/ ? current_slug.slice(/\A(.*)-([0-9]+)\Z/, 2) : nil
  end
end
